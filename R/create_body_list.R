#' Create a batch OSV query body
#'
#' @param pkg Character vector of package names.
#' @param version Optional character vector of package versions.
#' @return A list suitable for the OSV batch query endpoint, or `NULL`.
#' @keywords internal
create_body_list <- function(pkg = NULL, version = NULL) {

  if (is.null(pkg)) {
    message("no package to transform into body query")
    return(NULL)
  }

  if (any(is.na(pkg)) || any(pkg == "")) {
    stop("pkg should not contain missing or empty values")
  }


  if (!is.null(version) && length(pkg) != length(version)) {
    stop("pkg and version input must have the same length")
  }
  if (is.null(version)) {
    version <- vector(mode = "list", length = length(pkg))
  }

  body <- mapply(
    FUN = set_query,
    pkg = pkg,
    version = version,
    eco = "CRAN",
    SIMPLIFY = FALSE,
    USE.NAMES = FALSE
  )

  return(list(queries = body))
}
