testthat::test_that("it handles empty input", {
  testthat::expect_equal(
    format_vulnerabilities(NULL),
    "No known vulnerabilities found."
  )

  testthat::expect_equal(
    format_vulnerabilities(data.frame()),
    "No known vulnerabilities found."
  )

  testthat::expect_equal(
    format_vulnerabilities(data.table::data.table()),
    "No known vulnerabilities found."
  )
})

testthat::test_that("it handles grouped output", {
  x <- data.frame(
    package = c("b", "a"),
    installed = c("1", "1"),
    upstream = c("CVE-2", "CVE-1"),
    score = c(5, 9.8),
    severity = c("MEDIUM", "CRITICAL"),
    fix = c("no fix available", "2"),
    ref = c("[2]", "[1]")
  )
  grouped <- format_vulnerabilities(
    x = x,
    refs = c("path-a", "path-b"),
    group = TRUE
  )

  testthat::expect_named(grouped, c("summary", "details"))
  testthat::expect_match(grouped$summary, "2 vulnerabilities in 2 packages")
  testthat::expect_match(grouped$details, "a 1\n")
  testthat::expect_match(grouped$details, "b 1\n")
  testthat::expect_match(grouped$details, "path-a")
  testthat::expect_match(grouped$details, "path-b")



  not_grouped <- format_vulnerabilities(
    x = x,
    refs = c("path-a", "path-b"),
    group = FALSE
  )
  testthat::expect_named(not_grouped, c("summary", "details"))
  testthat::expect_match(not_grouped$summary, "2 vulnerabilities in 2 packages")
  testthat::expect_no_match(not_grouped$details, "a 1\n")
  testthat::expect_no_match(not_grouped$details, "b 1\n")
  testthat::expect_match(not_grouped$details, "path-a")
  testthat::expect_match(not_grouped$details, "path-b")

})


testthat::test_that("it handles missing input", {
  x <- data.frame(
    package = c("b", "a"),
    upstream = c("CVE-2", "CVE-1"),
    score = c(5, 9.8),
    severity = c("MEDIUM", "CRITICAL"),
    fix = c("no fix available", "2"),
    ref = c("[2]", "[1]")
  )

  testthat::expect_error(
    format_vulnerabilities(x = x, refs = c("path-a", "path-b")),
    "missing columns: 'installed'"
  )

})

testthat::test_that("it labels findings with missing severity as UNKNOWN", {
  x <- data.frame(
    package = "pkg",
    installed = "1.0",
    upstream = NA_character_,
    score = 0,
    severity = NA_character_,
    fix = "no fix available",
    ref = "[1]"
  )

  result <- format_vulnerabilities(x, group = FALSE)

  testthat::expect_match(result$summary, "UNKNOWN  1")
  testthat::expect_match(result$details, "UNKNOWN")
})
