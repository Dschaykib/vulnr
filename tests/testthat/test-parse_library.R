test_that("parse_library validates library paths", {
  expect_error(parse_library("missing-library"), "do not exist")
  expect_error(parse_library(NULL), "non-empty")

})

test_that("parse_library return a data.frame", {

  res <- parse_library()
  expect_equal(class(res), "data.frame")
  expect_contains(names(res), c("Package", "Version", "source", "path"))

})
