testthat::test_that("parse_dcf extracts dependencies and versions", {
  file <- tempfile(fileext = ".DESCRIPTION")
  on.exit(unlink(file))
  writeLines(c(
    "Package: fixture",
    "Version: 0.0.1",
    "Depends: R (>= 4.0), stats",
    "Imports: data.table (>= 1.14.0), jsonlite",
    "Suggests: testthat"
  ), file)

  result <- parse_dcf(file)

  testthat::expect_true(is.data.frame(result))
  testthat::expect_named(result, c("Package", "Version", "source", "path"))
  testthat::expect_false(any(result$Package == "R"))
  testthat::expect_true(any(result$Package == "data.table"))
  testthat::expect_equal(unique(result$source), "DESCRIPTION")
  testthat::expect_equal(unique(result$path), file)
})

testthat::test_that("parse_dcf rejects missing files", {
  testthat::expect_error(parse_dcf("missing-DESCRIPTION"), "does not exit")
})
