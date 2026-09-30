#' Check an R project's dependencies for known vulnerabilities
#'
#' This is the CI-facing entry point. The scanner implementation will be
#' added in a later iteration.
#'
#' @param ... Passed to [scan()].
#' @param fail Whether to error when vulnerabilities are found.
#' @return A scan result, invisibly when `fail` is `TRUE` and no findings exist.
#' @export
check <- function(..., fail = TRUE) {
  result <- scan(...)

  has_findings <- any(vapply(result, length, integer(1)) > 0L)

  if (fail && has_findings) {
    stop("Known vulnerabilities found in project dependencies.", call. = FALSE)
  }

  result
}

#' Scan project dependency files
#'
#' @param renv_lock Path to an `renv.lock` file.
#' @param description Path to a `DESCRIPTION` file.
#' @return A list containing scan findings.
#' @export
scan <- function(renv_lock = "renv.lock", description = "DESCRIPTION") {
  list(
    renv = scan_renv(renv_lock),
    description = scan_description(description)
  )
}

#' Scan an `renv.lock` file
#'
#' @param path Path to the lockfile.
#' @return An empty findings list until the vulnerability backend is connected.
#' @export
scan_renv <- function(path = "renv.lock") {
  if (!file.exists(path)) {
    return(list())
  }

  res <- rosv::osv_scan(mode = "renv", dir = dirname(path))


  aa <- rosv::osv_vulns("RSEC-2025-1")
  bb <- rosv::osv_vulns("RSEC-2026-0")

  x <- rosv::osv_query_1(
    name = "plotly",
    ecosystem = "CRAN"
  )
  x$content

  A <- rosv::get_content(aa)
  return(res)

}

#' Scan package dependencies declared in `DESCRIPTION`
#'
#' @param path Path to the package `DESCRIPTION` file.
#' @return An empty findings list until the vulnerability backend is connected.
#' @export
scan_description <- function(path = "DESCRIPTION") {
  if (!file.exists(path)) {
    return(list())
  }

  list()
}
