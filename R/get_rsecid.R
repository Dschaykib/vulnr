#' Extract vulnerability identifiers from OSV results
#'
#' @param body_list Batch query body used to create `results`.
#' @param results Parsed OSV batch results.
#' @return A data table of packages, installed versions, and OSV identifiers.
#' @importFrom data.table data.table rbindlist
#' @keywords internal
get_rsecid <- function(body_list, results) {

  i_res <- 4
  resc_list <- vector(mode = "list", length = length(results))
  for (i_res in seq_along(results)) {
    if (length(results[[i_res]]) == 0) {
      next()
    }
    this_pkg <- body_list$queries[[i_res]]$package$name
    this_version <- body_list$queries[[i_res]]$version

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
