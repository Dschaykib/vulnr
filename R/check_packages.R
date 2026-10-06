#' Query OSV for package vulnerabilities
#'
#' @param check_data Data frame containing `Package` and `Version` columns.
#' @return A data table of vulnerabilities and severity information, or `NULL`.
#' @importFrom data.table merge.data.table
#' @keywords internal
check_packages <- function(check_data) {

  # check for data.table
  if (!data.table::is.data.table(check_data)) {
    check_data <- data.table::as.data.table(check_data)
  }

  # check for version ranges
  idx <- grepl("[<>]", check_data$Version)
  check_data[idx, range := Version]
  check_data[idx, Version := NA_character_]

  # create list input
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

  # merge version ranges back and selected relative ones
  cve_dt_range <- data.table::merge.data.table(
    x = cve_dt,
    y = check_data,
    by.x = c("package", "installed"),
    by.y = c("Package", "Version"),
    all = TRUE
  )


  cve_dt_range$keep <- TRUE
  cve_dt_range[
    is.na(installed) & !is.na(range),
    keep := compare_version(x = fix, y = range),
    by = names(cve_dt_range)
  ]

  # remove helper columns
  cve_dt_range <- cve_dt_range[keep == TRUE, ]
  cve_dt_range$keep <- NULL
  cve_dt_range$range <- NULL


  # add severity info
  cves <- data.table::merge.data.table(
    x = cve_dt_range,
    y = severity_dt,
    by = "upstream"
  )

  return(cves)

}
