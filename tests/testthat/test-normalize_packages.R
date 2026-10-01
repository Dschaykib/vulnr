test_that("normalize_packages validates and annotates data", {
  out <- normalize_packages(data.frame(Package = "foo", Version = "1.0"))
  expect_named(out, c("Package", "Version", "source", "path"))
  expect_equal(out$source, "data")
  expect_error(normalize_packages(data.frame(Package = "foo")), "Version")
  expect_error(
    normalize_packages(data.frame(Package = "", Version = "1")),
    "empty"
  )
  expect_error(normalize_packages(1), "data frame")
})
