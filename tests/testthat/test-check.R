testthat::test_that("check validates error levels", {
  data <- data.frame(Package = "x", Version = "1")
  testthat::expect_error(
    check(data = data, renv_file = NULL, lib = NULL, error_level = "bad"),
    "error_level"
  )
  testthat::expect_error(
    check(
      data = data, renv_file = NULL, lib = NULL,
      error_level = c("LOW", "HIGH")
    ),
    "error_level"
  )
})

testthat::test_that("check can run with no sources", {
  testthat::expect_error(check(renv_file = NULL, lib = NULL), NA)
})

testthat::test_that("check reports mocked vulnerabilities", {
  findings <- data.table::data.table(
    package = "foo", installed = "1.0", upstream = "CVE-1", score = 9.8,
    severity = "CRITICAL", fix = "1.1", ref = "[1]"
  )
  testthat::local_mocked_bindings(
    check_packages = function(x) findings, .package = "vulr"
  )
  testthat::expect_error(
    check(
      data = data.frame(Package = "foo", Version = "1.0"),
      renv_file = NULL, lib = NULL, error_level = "HIGH"
    ),
    "Found 1 vulnerability"
  )
})
