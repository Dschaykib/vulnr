#' Normalize package data
#'
#' @param x A data frame with `Package` and `Version` columns, or a character
#'   vector of package names. A missing or empty version is treated as an
#'   unversioned package query.
#' @return A normalized data frame with `Package`, `Version`, `source`,
#'  and `path` columns.
#' @keywords internal
normalize_packages <- function(x) {

  if (!is.data.frame(x) && !is.vector(x)) {
    stop("`x` must be a data frame or a vector", call. = FALSE)
  }


  # if only a vector was provided, create a data.frame
  if (is.vector(x)) {
    x <- data.frame(
      Package = x,
      Version = NA_character_
    )
  }


  required <- c("Package", "Version")
  missing <- setdiff(required, names(x))

  if (length(missing) > 0L) {
    stop(
      sprintf(
        "`x` is missing required column%s: %s.",
        if (length(missing) > 1L) "s" else "",
        paste(missing, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  out <- data.frame(
    Package = as.character(x$Package),
    Version = as.character(x$Version),
    row.names = NULL,
    stringsAsFactors = FALSE
  )

  invalid_package <- is.na(out$Package) | trimws(out$Package) == ""
  msg <- character()

  if (any(invalid_package)) {
    msg <- c(
      msg,
      sprintf(
        "`Package` contains missing or empty values in row%s: %s.",
        if (sum(invalid_package) > 1L) "s" else "",
        paste(which(invalid_package), collapse = ", ")
      )
    )
  }

  if (length(msg) > 0L) {
    stop(paste(msg, collapse = "\n"), call. = FALSE)
  }

  out$source <- "data"
  out$path <- "custom input data"

  return(out)
}
