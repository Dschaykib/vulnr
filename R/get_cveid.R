#' Retrieve upstream identifiers and fixed versions
#'
#' @param resc_dt Data table of OSV result identifiers.
#' @return A data table linking packages to upstream vulnerability identifiers.
#' @importFrom data.table rbindlist
#' @keywords internal
get_cveid <- function(resc_dt) {

  empty_result <- data.table::data.table(
    package = character(),
    installed = character(),
    id = character(),
    upstream = character(),
    fix = character()
  )

  # initialize list with at least one empty result
  cve_list <- vector(mode = "list", length = nrow(resc_dt))
  cve_list[[1]] <- empty_result

  for (i_row in seq_along(resc_dt$id)) {

    i_id <- resc_dt$id[i_row]
    this_url <- paste0("https://api.osv.dev/v1/vulns/", i_id)
    cve_request_content <- api_request(url = this_url, verb = "GET")

    out <- resc_dt[i_row, ]

    # get upstream
    this_upstream <- cve_request_content$upstream
    if (is.null(this_upstream)) {
      this_upstream <- NA_character_
    }

    out <- out[, list(upstream = unlist(this_upstream)),
               by = c("package", "installed", "id")]

    # get fixed version
    fixed_version <- tryCatch(
      cve_request_content$affected[[1]]$ranges[[1]]$events[[2]]$fixed,
      error = function(e) {
        "no fix available"
      }
    )
    out$fix <- fixed_version

    cve_list[[i_id]] <- out

  }


  cve_dt <- data.table::rbindlist(cve_list, fill = TRUE, use.names = TRUE)

  return(cve_dt)
}
