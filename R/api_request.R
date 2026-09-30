#' Send a request to the OSV API
#'
#' @param url API endpoint URL.
#' @param verb HTTP method, either `GET` or `POST`.
#' @param body Optional request body, converted to JSON for `POST` requests.
#' @return The parsed API response.
#' @import httr
#' @importFrom jsonlite toJSON
#' @keywords internal
api_request <- function(url,
                        verb = c("GET", "POST"),
                        body = NULL) {
  verb <- match.arg(verb)

  response <- tryCatch(
    httr::RETRY(
      verb = verb,
      url = url,
      body = if (!is.null(body)) {
        jsonlite::toJSON(body, auto_unbox = TRUE)
      },
      httr::content_type_json(),
      httr::timeout(30),
      times = 3,
      pause_min = 1,
      pause_cap = 10,
      terminate_on = c(400, 401, 403, 404)
    ),
    error = function(e) {
      stop(
        "Failed to connect to API: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )

  if (httr::http_error(response)) {
    stop(
      sprintf(
        "API request failed with HTTP %s: %s",
        httr::status_code(response),
        httr::http_status(response)$message
      ),
      call. = FALSE
    )
  }

  tryCatch(
    httr::content(response, as = "parsed"),
    error = function(e) {
      stop(
        "Failed to parse API response: ",
        conditionMessage(e),
        call. = FALSE
      )
    }
  )
}
