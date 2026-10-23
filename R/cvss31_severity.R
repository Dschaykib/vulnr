#' Convert a CVSS score to a severity label
#'
#' @param score Numeric CVSS score.
#' @return One of `NONE`, `LOW`, `MEDIUM`, `HIGH`, or `CRITICAL`.
#' @examples
#' cvss31_severity(9.8)
#' @export
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
