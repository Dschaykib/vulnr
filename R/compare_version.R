#' Compare a package version with a constraint
#'
#' @param x Package version to compare.
#' @param y Version constraint using `>`, `>=`, `<`, `<=`, `=` or `==`.
#' @return A logical value indicating whether `x` satisfies `y`.
#'
#' @keywords internal
#' @importFrom utils compareVersion
compare_version <- function(x, y) {
  # Extract operator and version
  match <- regexec("^(>=|<=|>|<|==|=)\\s*(.+)$", y)
  parts <- regmatches(y, match)[[1]]

  if (length(parts) != 3) {
    stop("Invalid version constraint: ", y)
  }

  operator <- parts[2]
  version <- parts[3]

  # 0 if the numbers are equal, -1 if b is later and 1 if a is later
  cmp <- utils::compareVersion(x, version)

  switch(
    operator,
    ">=" = cmp >= 0,
    "<=" = cmp <= 0,
    ">"  = cmp > 0,
    "<"  = cmp < 0,
    "==" = cmp == 0,
    "="  = cmp == 0
  )
}
