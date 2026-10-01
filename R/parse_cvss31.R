#' Calculate a CVSS 3.1 base score
#'
#' @param vector A CVSS 3.1 vector string.
#' @return A numeric score between 0 and 10.
#' @keywords internal
cvss31_score <- function(vector) {
  # Remove prefix and parse metrics
  vector <- sub("^CVSS:3\\.1/", "", vector)
  parts <- strsplit(vector, "/", fixed = TRUE)[[1]]

  metrics <- setNames(
    sub("^[^:]+:", "", parts),
    sub(":.*$", "", parts)
  )

  required <- c("AV", "AC", "PR", "UI", "S", "C", "I", "A")
  if (!all(required %in% names(metrics))) {
    stop("Invalid CVSS 3.1 vector: missing required base metrics.")
  }

  # Metric weights
  AV <- c(N = 0.85, A = 0.62, L = 0.55, P = 0.20)[metrics["AV"]]
  AC <- c(L = 0.77, H = 0.44)[metrics["AC"]]
  UI <- c(N = 0.85, R = 0.62)[metrics["UI"]]

  # PR depends on Scope
  if (metrics["S"] == "U") {
    PR <- c(N = 0.85, L = 0.62, H = 0.27)[metrics["PR"]]
  } else {
    PR <- c(N = 0.85, L = 0.68, H = 0.50)[metrics["PR"]]
  }

  impact_weights <- c(H = 0.56, L = 0.22, N = 0)
  C <- impact_weights[metrics["C"]]
  I <- impact_weights[metrics["I"]]
  A <- impact_weights[metrics["A"]]

  # Impact Sub-Score
  iss <- 1 - ((1 - C) * (1 - I) * (1 - A))

  # Impact
  if (metrics["S"] == "U") {
    impact <- 6.42 * iss
  } else {
    impact <- 7.52 * (iss - 0.029) -
      3.25 * (iss - 0.02)^15
  }

  # No impact => score is 0
  if (impact <= 0) {
    return(0)
  }

  # Exploitability
  exploitability <- 8.22 * AV * AC * PR * UI

  # CVSS uses "round up" rather than normal rounding
  roundup <- function(x) {
    ceiling(x * 10 - 1e-10) / 10
  }

  # Base score
  if (metrics["S"] == "U") {
    score <- roundup(min(impact + exploitability, 10))
  } else {
    score <- roundup(min(1.08 * (impact + exploitability), 10))
  }

  unname(score)
}

#' Convert a CVSS score to a severity label
#'
#' @param score Numeric CVSS score.
#' @return One of `NONE`, `LOW`, `MEDIUM`, `HIGH`, or `CRITICAL`.
#' @keywords internal
cvss31_severity <- function(score) {
  if (score == 0) {
    "NONE"
  } else if (score < 4.0) {
    "LOW"
  } else if (score < 7.0) {
    "MEDIUM"
  } else if (score < 9.0) {
    "HIGH"
  } else {
    "CRITICAL"
  }
}


#' Parse a CVSS 3.1 vector
#'
#' @param vector A CVSS 3.1 vector string.
#' @return A list containing the original vector, numeric score, and severity.
#' @keywords internal
parse_cvss31 <- function(vector) {
  score <- cvss31_score(vector)

  list(
    severity = cvss31_severity(score),
    score = score,
    vector = vector
  )
}
