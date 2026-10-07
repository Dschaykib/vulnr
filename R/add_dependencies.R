#' Add recursive package dependencies
#'
#' Resolves strong recursive dependencies from the latest CRAN metadata and
#' appends dependencies that are not already present in `data`.
#'
#' @param data Data frame containing a `Package` column.
#' @return A data table containing the input packages and their dependencies.
#'
#' @keywords internal
#' @importFrom tools package_dependencies
#' @import data.table
#'
add_dependencies <- function(data) {

  # including for package build notes
  path <- Package <- NULL

  message("To get the dependencies, the latest CRAN version are used.")

  pkg <- data$Package

  deps <- tools::package_dependencies(
    packages = pkg,
    recursive = TRUE,
    reverse = FALSE,
    which = "strong"
  )


  # TODO function to check a pkg on CRAN
  # TODO check a package given a DESCRIPTION file
  dep_list <- vector(mode = "list", length = length(pkg))
  names(dep_list) <- pkg
  i_pkg <- pkg[1]
  for (i_pkg in pkg) {

    pkg_deps <- unlist(deps[[i_pkg]])
    if (is.null(pkg_deps)) {
      next()
    }

    # set source as dependency and the path as "parent" package
    dep_list[[i_pkg]] <- data.table::data.table(
      Package = pkg_deps,
      Version = NA_character_,
      source = "dependency",
      path = i_pkg
    )
  }

  dep_dt <- data.table::rbindlist(dep_list, use.names = TRUE, fill = TRUE)

  # remove dependencies, that are already in the data
  # combine dependencies for later print outs
  revdep_dt <- dep_dt[
    !Package %in% pkg,
    list(path = paste0("dependency of ", paste0(path, collapse = ", "))),
    by = c("Package", "Version", "source")
  ]

  out <- data.table::rbindlist(
    list(data, revdep_dt),
    use.names = TRUE,
    fill = TRUE
  )

  return(out)
}
