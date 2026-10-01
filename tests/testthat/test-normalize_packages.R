test_that("normalize_packages validates and annotates data", {
  out <- normalize_packages(data.frame(Package = "foo", Version = "1.0"))
  expect_named(out, c("Package", "Version", "source", "path"))
  expect_equal(out$source, "data")
  out <- normalize_packages(c("foo", "bar"))
  expect_equal(out$Package, c("foo", "bar"))
  expect_true(all(is.na(out$Version)))
  expect_equal(out$path, c("custom input data", "custom input data"))
  expect_silent(normalize_packages(data.frame(Package = "foo", Version = NA)))
  expect_silent(normalize_packages(data.frame(Package = "foo", Version = "")))
  expect_error(normalize_packages(data.frame(Package = "foo")), "Version")
  expect_error(
    normalize_packages(data.frame(Package = "", Version = "1")),
    "empty"
  )
  expect_error(normalize_packages(factor("foo")), "data frame or a vector")
})
