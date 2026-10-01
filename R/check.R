#' Check R dependencies for known vulnerabilities
#'
#' Scans explicitly supplied package data, an `renv.lock` file, and installed
#' libraries, then queries the OSV database for known vulnerabilities.
#'
#' @param data Optional data frame with `Package` and `Version` columns.
#' @param renv_file Path to an `renv.lock` file, or `NULL` to skip it.
#' @param lib Character vector of library paths, or `NULL` to skip
#' installed libraries.
#' @param error_level Minimum severity that causes an error. One of `CRITICAL`,
#'   `HIGH`, `MEDIUM`, or `LOW`.
#' @param group Logical; if `TRUE`, group findings by package in the report.
#' @param return_cves Logical; if `TRUE`, return the CVE data table instead of
#'   reporting findings with a warning or error.
#'
#' @return Invisibly returns `NULL` by default. If `return_cves` is `TRUE`,
#'   returns the CVE data table.
#'
#' @importFrom data.table rbindlist
#' @export
check <- function(
    data = NULL,
    renv_file = "renv.lock",
    lib = .libPaths(),
    error_level = "LOW",
    group = TRUE,
    return_cves = FALSE) {


  # including for package build notes
  path <- NULL

  # validate inputs
  severity_levels <- c("CRITICAL", "HIGH", "MEDIUM", "LOW")
  if (length(error_level) != 1L || !error_level %in% severity_levels) {
    stop(
      paste0(
        "'error_level' must be one of: ",
        paste0(severity_levels, collapse = ", ")
      )
    )
  }

  if (!is.logical(return_cves) || length(return_cves) != 1L ||
      is.na(return_cves)) {
    stop("'return_cves' must be a single non-missing logical value")
  }


  # Validate that at most one source was supplied
  inputs <- list()

  if (!is.null(data)) {
    inputs$data <- normalize_packages(x = data)
  }

  if (!is.null(renv_file)) {
    inputs$renv <- parse_renv_lock(renv_file = renv_file)
  }

  if (!is.null(lib)) {
    inputs$lib <- parse_library(lib = lib)
  }

  if (length(inputs) == 0L) {
    message("No known vulnerabilities found.")
    return(invisible(NULL))
  }

  inputs_all <- data.table::rbindlist(inputs)

  # actual vulnerability check
  check_data <- unique(inputs_all[, c("Package", "Version")])
  cves <- check_packages(check_data)

  # add path info back to cves
  cves_merged <- data.table::merge.data.table(
    x = cves,
    y = inputs_all,
    by.x = c("package", "installed"),
    by.y = c("Package", "Version")
  )

  path_info <- sort(unique(cves_merged$path))
  cves_merged$path <- as.numeric(
    factor(
      x = cves_merged$path,
      levels = path_info
    )
  )

  cves_full <- cves_merged[
    , list(ref = paste0("[", paste0(sort(path), collapse = ", "), "]")),
    by = names(cves)
  ]


  if (return_cves) {
    return(cves_full)
  }

  # report CVEs
  msg <- format_vulnerabilities(cves_full, group = group, refs = path_info)

  error_idx <- which(error_level == severity_levels)
  severity_idx <- match(cves$severity, severity_levels)


  if (any(severity_idx <= error_idx)) {
    message(msg$details)
    stop(msg$summary, call. = FALSE)
  }

  if (!is.null(cves) && nrow(cves) != 0) {
    message(msg$details)
    warning(msg$summary, call. = FALSE)
  } else {
    message(msg)
  }

  return(NULL)
}
