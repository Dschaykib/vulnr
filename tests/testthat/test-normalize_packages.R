testthat::test_that("normalize_packages validates and annotates data", {
  out <- normalize_packages(data.frame(Package = "foo", Version = "1.0"))
  testthat::expect_named(out, c("Package", "Version", "source", "path"))
  testthat::expect_equal(out$source, "data")
  out <- normalize_packages(c("foo", "bar"))
  testthat::expect_equal(out$Package, c("foo", "bar"))
  testthat::expect_true(all(is.na(out$Version)))
  testthat::expect_equal(out$path, c("custom input data", "custom input data"))
  testthat::expect_silent(
    normalize_packages(data.frame(Package = "foo", Version = NA))
  )
  testthat::expect_silent(
    normalize_packages(data.frame(Package = "foo", Version = ""))
  )
  testthat::expect_error(
    normalize_packages(data.frame(Package = "foo")),
    "Version"
  )
  testthat::expect_error(
    normalize_packages(data.frame(Package = "", Version = "1")),
    "empty"
  )
  testthat::expect_error(
    normalize_packages(factor("foo")),
    "data frame or a vector"
  )
})
