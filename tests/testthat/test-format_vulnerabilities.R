test_that("format_vulnerabilities handles empty, grouped, and flat output", {
  expect_equal(
    format_vulnerabilities(NULL),
    "✔ No known vulnerabilities found."
  )
  x <- data.frame(
    package = c("b", "a"),
    installed = c("1", "1"),
    upstream = c("CVE-2", "CVE-1"),
    score = c(5, 9.8),
    severity = c("MEDIUM", "CRITICAL"),
    fix = c("no fix available", "2"),
    ref = c("[2]", "[1]")
  )
  grouped <- format_vulnerabilities(x, refs = c("path-a", "path-b"))

  expect_named(grouped, c("summary", "details"))
  expect_match(grouped$summary, "2 vulnerabilities in 2 packages")

  res <- format_vulnerabilities(x, group = FALSE)
  expect_match(res$details, "Package")
  expect_match(res$details, "CVE-1")
  expect_match(res$details, "CVE-2")

})
