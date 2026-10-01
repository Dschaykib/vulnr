#' Parse installed packages from library paths
#'
#' @param lib Character vector of existing library paths.
#' @return A data frame of installed packages and their source paths.
#' @importFrom utils installed.packages
#' @keywords internal
parse_library <- function(lib = .libPaths()) {

  if (!is.character(lib) || length(lib) == 0L) {
    stop("`lib` must be a non-empty character vector.", call. = FALSE)
  }

  missing_lib <- !dir.exists(lib)

  if (any(missing_lib)) {
    stop(
      sprintf(
        "Library path%s do not exist: %s.",
        if (sum(missing_lib) > 1L) "s" else "",
        paste(lib[missing_lib], collapse = ", ")
      ),
      call. = FALSE
    )
  }

  pkgs <- utils::installed.packages(lib.loc = lib)

  out <- normalize_packages(
    data.frame(
      Package = pkgs[, "Package"],
      Version = pkgs[, "Version"],
      row.names = NULL,
      stringsAsFactors = FALSE
    )
  )

  out$source <- "lib"
  out$path <- pkgs[, "LibPath"]

  return(out)
}
