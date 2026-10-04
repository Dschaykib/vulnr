#' Query OSV for package vulnerabilities
#'
#' @param check_data Data frame containing `Package` and `Version` columns.
#' @return A data table of vulnerabilities and severity information, or `NULL`.
#' @importFrom data.table merge.data.table
#' @keywords internal
check_packages <- function(check_data) {

  # cretae list input
  body_list <- create_body_list(
    pkg = check_data$Package,
    version = check_data$Version
  )


  osv_content <- api_request(
    url = "https://api.osv.dev/v1/querybatch",
    verb = "POST",
    body = body_list
  )


  # get RSEC ids
  resc_dt <- get_rsecid(
    body_list = body_list,
    results = osv_content$results
  )

  # get severity from upstream CVE
  cve_dt <- get_cveid(resc_dt = resc_dt)
  severity_dt <- get_severity(ids = unique(cve_dt$upstream))


  cves <- data.table::merge.data.table(
    x = cve_dt,
    y = severity_dt,
    by = "upstream",
    all = TRUE
  )

  return(cves)

}
