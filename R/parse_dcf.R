parse_dcf <- function(file = "DESCRIPTION") {

  #file <- "DESCRIPTION"
  #file <- "/Users/jakobgepp/Library/Caches/org.R-project.R/R/renv/cache/v5/macos/R-4.5/aarch64-apple-darwin20/dplyr/1.2.1/d71f190466b9496cf8543c76641be5cf/dplyr/DESCRIPTION"

  # TODO adjust for multiple file inputs

  file_idx <- !file.exists(file)
  if (any(file_idx)) {
    stop("file does not exit: '", paste0(file[file_idx], collapse = "', '"), "'")
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
