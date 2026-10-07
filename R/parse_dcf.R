#' Parse package dependencies from DESCRIPTION files
#'
#' Reads `Depends`, `Imports`, and `Suggests` fields and returns one row per
#' package, excluding the base R dependency.
#'
#' @details
#' For the output, the source is set to 'DESCRIPTION' and the path are the
#' packages that depend on it.
#'
#' @param file Character vector of existing DESCRIPTION file paths.
#' @return A data table with `Package`, `Version`, `source`, and `path`.
#' @keywords internal
parse_dcf <- function(file = "DESCRIPTION") {

  # TODO adjust for multiple file inputs

  # include to dissmis NOTE in pkg build
  Package <- NULL

  file_idx <- !file.exists(file)
  if (any(file_idx)) {
    stop(
      "file does not exit: '",
      paste0(file[file_idx], collapse = "', '"),
      "'"
    )
  }

  desc <- read.dcf(file)[1, ]
  fields <- intersect(c("Depends", "Imports", "Suggests"), names(desc))

  packages <- trimws(unlist(strsplit(desc[fields], ",")))
  packages <- packages[nzchar(packages)]

  package_names <- sub("\\s*\\(.*\\)$", "", packages)



  versions <- ifelse(
    grepl("\\(", packages),
    sub("^.*\\((.*)\\)$", "\\1", packages),
    NA_character_
  )
  versions <- gsub("\\\n", " ", versions)

  out <- data.table::data.table(
    Package = package_names,
    Version = versions,
    source = "DESCRIPTION",
    path = file
  )

  # filter out R Version
  out <- out[Package != "R", ]


  return(out)
}
