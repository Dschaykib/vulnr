#' Build an OSV package query
#'
#' @param pkg Package name.
#' @param version Optional package version.
#' @param eco Package ecosystem, defaulting to `CRAN`.
#' @return A list representing one OSV query.
#' @keywords internal
set_query <- function(pkg, version = NULL, eco = "CRAN") {

  if (is.null(version) || is.na(version) || trimws(version) == "") {
    out <- list(
      package = list(
        name = pkg,
        ecosystem = eco
      )
    )
  } else {
    out <- list(
      version = version,
      package = list(
        name = pkg,
        ecosystem = eco
      )
    )

  }
  return(out)
}
