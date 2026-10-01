testthat::test_that("parse_library validates library paths", {
  testthat::expect_error(parse_library("missing-library"), "do not exist")
  testthat::expect_error(parse_library(NULL), "non-empty")

})

testthat::test_that("parse_library return a data.frame", {

  res <- parse_library()
  testthat::expect_equal(class(res), "data.frame")
  testthat::expect_contains(
    names(res),
    c("Package", "Version", "source", "path")
  )

})
