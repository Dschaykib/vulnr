compare_version <- function(x, y) {
  # Extract operator and version
  match <- regexec("^(>=|<=|>|<|==|=)\\s*(.+)$", y)
  parts <- regmatches(y, match)[[1]]

  if (length(parts) != 3) {
    stop("Invalid version constraint: ", y)
  }

  operator <- parts[2]
  version <- parts[3]

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
