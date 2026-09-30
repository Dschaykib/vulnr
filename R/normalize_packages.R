#' Normalize package data
#'
#' @param x Data frame with `Package` and `Version` columns.
#' @return A normalized data frame with `Package`, `Version`, `source`, and `path` columns.
#' @keywords internal
normalize_packages <- function(x) {
  if (!is.data.frame(x)) {
    stop("`x` must be a data frame.", call. = FALSE)
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
  invalid_version <- is.na(out$Version) | trimws(out$Version) == ""

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

  if (any(invalid_version)) {
    msg <- c(
      msg,
      sprintf(
        "`Version` contains missing or empty values in row%s: %s.",
        if (sum(invalid_version) > 1L) "s" else "",
        paste(which(invalid_version), collapse = ", ")
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
