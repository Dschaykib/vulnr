#' Extract vulnerability identifiers from OSV results
#'
#' @param body_list Batch query body used to create `results`.
#' @param results Parsed OSV batch results.
#' @return A data table of packages, installed versions, and OSV identifiers.
#' @importFrom data.table data.table rbindlist
#' @keywords internal
get_rsecid <- function(body_list, results) {

  empty_result <- data.table::data.table(
    package = character(),
    installed = character(),
    id = character(),
    fix = character()
  )

  i_res <- 4
  resc_list <- vector(mode = "list", length = length(results))
  for (i_res in seq_along(results)) {
    if (length(results[[i_res]]) == 0) {
      resc_list[[i_res]] <- empty_result
      next()
    }
    this_pkg <- body_list$queries[[i_res]]$package$name
    this_version <- body_list$queries[[i_res]]$version
    if (is.null(this_version)) {
      this_version <- NA_character_
    }

    resc_list[[i_res]] <- data.table::data.table(
      package = this_pkg,
      installed = this_version,
      id = sapply(results[[i_res]]$vulns, function(x) x$id),
      fix = NA_character_
    )
  }


  resc_dt <- data.table::rbindlist(resc_list, fill = TRUE, use.names = TRUE)
  return(resc_dt)
}
