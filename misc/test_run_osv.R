
# Example usage
data <- check_data <- data.frame(
  Package = c("ggplot2", "gdata", "commonmark", "gh"),
  Version = c("3.1.1", "2.16.1", "1.0", "1.5.0")
)
data <- data.frame(
  Package = c("commonmark"),
  Version = NA_character_
)

check_data <- data.frame(
  Package = c("commonmark"),
  Version = NA_character_
)

check_data <- data.table::data.table(
  Package = c("commonmark"),
  Version = ">= 1.8.1"
)


check_data <- data.frame(
  Package = c("commonmark"),
  Version = c("1.7")
)
check_data <- data.frame(
  Package = c("widgetframe"),
  Version = c("0.3.1")
)
check_data <- data.frame(
  Package = c("zip"),
  Version = c("1.7")
)

check_data <- data.frame(
  Package = c("plotly", "widgetframe", "zip", "commonmark"),
  Version = c("2.0.2", "0.3.1", "3.0.0", "1.7")
)

# from installed packages
check_data <- as.data.frame(
  x = installed.packages()[, c("Package", "Version")],
  row.names = FALSE,
  stringsAsFactors = FALSE
)


# from renv file
check_data <- parse_renv_lock(renv_file = "renv.lock")


# -------------------------------------------------------------------------



body_list <- create_body_list(
  pkg = check_data$Package,
  version = check_data$Version
)




# -------------------------------------------------------------------------


# body_list <- list(
#   queries = list(
#     list(
#       version = "2.0.2",
#       package = list(
#         name = "plotly",
#         ecosystem = "CRAN"
#       )
#     ),
#     list(
#       version = "0.3.1",
#       package = list(
#         name = "widgetframe",
#         ecosystem = "CRAN"
#       )
#     ),
#     list(
#       version = "3.0.0",
#       package = list(
#         name = "zip",
#         ecosystem = "CRAN"
#       )
#     ),
#     list(
#       version = "1.7",
#       package = list(
#         name = "commonmark",
#         ecosystem = "CRAN"
#       )
#     )
#   )
# )

#
#
# body_list <- list(
#   queries = list(
#     list(
#       version = "2.0.2",
#       package = list(
#         name = "plotly",
#         ecosystem = "CRAN"
#       )
#     )
#   )
# )
#
# body_list <- list(
#   queries = list(
#     list(
#       version = "4.12.0",
#       package = list(
#         name = "plotly",
#         ecosystem = "CRAN"
#       )
#     )
#   )
# )

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






# -------------------------------------------------------------------------

# get severity from upstream CVE
cve_dt <- get_cveid(resc_dt = resc_dt)
severity_dt <- get_severity(ids = unique(cve_dt$upstream))


if (nrow(severity_dt) > 0 && nrow(cve_dt) > 0) {
  cves <- data.table::merge.data.table(
    x = cve_dt,
    y = severity_dt,
    by = "upstream"
  )
} else {
  cves <- NULL
}

severity_levels <- c("CRITICAL", "HIGH", "MEDIUM", "LOW")
error_level <- "HIGH"
error_level <- "CRITICAL"
error_idx <- which(error_level == severity_levels)
severity_idx <- match(cves$severity, severity_levels)

msg <- format_vulnerabilities(cves, group = TRUE)

if (any(severity_idx <= error_idx)) {
  stop(msg,call. = FALSE)
}

if (!is.null(cves) || nrow(cves) != 0) {
  warning(msg, call. = FALSE)
} else {
  message(msg)
}





# -------------------------------------------------------------------------
data <- data.frame(
  Package = c("commonmark", "gh", "dplyr", "adepro"),
  Version = c("1.7", NA_character_, "1.2.1", "4.2.7")
)

data <- c("commonmark", "gh")

aa <- check(data = data, renv_file = NULL, lib = NULL)
bb <- normalize_packages(x = data)

cc <- check(data = data, renv_file = NULL, lib = NULL, dependencies = TRUE)

check_packages(check_data = check_data)

# TODO check why Source is empty
devtools::load_all()
debugonce(check_packages)
debugonce(check)
vulnr::check(lib = NULL, dcf = "DESCRIPTION", dependencies = TRUE)
dcf_file <- "/Users/jakobgepp/Library/Caches/org.R-project.R/R/renv/cache/v5/macos/R-4.5/aarch64-apple-darwin20/dplyr/1.2.1/d71f190466b9496cf8543c76641be5cf/dplyr/DESCRIPTION"
vulnr::check(renv_file = NULL, lib = NULL, dcf = dcf_file, dependencies = TRUE)

vulnr::check(renv_file = "renv.lock", lib = NULL, dcf = dcf_file, dependencies = TRUE)
