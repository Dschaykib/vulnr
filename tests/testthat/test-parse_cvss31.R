testthat::test_that("CVSS parsing calculates scores and labels", {
  vector <- "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H"
  testthat::expect_equal(cvss31_score(vector), 9.8)
  testthat::expect_equal(
    parse_cvss31(vector),
    list(severity = "CRITICAL", score = 9.8, vector = vector)
  )
  testthat::expect_equal(cvss31_severity(0), "NONE")
  testthat::expect_equal(cvss31_severity(4), "MEDIUM")
  testthat::expect_error(cvss31_score("CVSS:3.1/AV:N"), "missing required")
})
