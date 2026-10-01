#' Retrieve CVSS severity for vulnerability identifiers
#'
#' @param ids Character vector of upstream vulnerability identifiers.
#' @return A data table with identifiers, CVSS scores, and severity labels.
#' @importFrom data.table data.table rbindlist
#' @keywords internal
get_severity <- function(ids) {

  empty_result <- data.table::data.table(
    upstream = character(),
    score = numeric(),
    severity = character()
  )

  # initialize list with at least one empty result
  id_list <- vector(mode = "list", length = length(ids))
  id_list[[1]] <- empty_result

  i_id <- ids[1]
  for (i_id in ids) {
    this_url <- paste0("https://api.osv.dev/v1/vulns/", i_id)
    cve_request_content <- api_request(url = this_url, verb = "GET")

    vector <- cve_request_content$severity[[1]]$score

    score <- cvss31_score(vector)
    severity <- cvss31_severity(score)

    out <- data.table::data.table(
      upstream = i_id,
      score = score,
      severity = severity
    )


    id_list[[i_id]] <- out

  }

  id_dt <- data.table::rbindlist(
    id_list,
    fill = TRUE,
    use.names = TRUE
  )

  return(id_dt)
}
