testthat::test_that("compare_version supports all operators", {
  testthat::expect_true(compare_version("1.2.0", ">= 1.1.0"))
  testthat::expect_true(compare_version("1.2.0", "<= 1.2.0"))
  testthat::expect_true(compare_version("1.2.0", "> 1.1.0"))
  testthat::expect_true(compare_version("1.2.0", "< 2.0.0"))
  testthat::expect_true(compare_version("1.2.0", "= 1.2.0"))
  testthat::expect_true(compare_version("1.2.0", "== 1.2.0"))
  testthat::expect_false(compare_version("1.2.0", "> 1.2.0"))
})

testthat::test_that("compare_version rejects invalid constraints", {
  testthat::expect_error(compare_version("1.0", "1.0"), "Invalid version")
})


testthat::test_that("compare_version supports different version formats", {
  # Dot-separated versions
  testthat::expect_true(compare_version("1.2.0", ">= 1.1.0"))

  # different deepth
  testthat::expect_true(compare_version("2", ">= 1"))
  testthat::expect_true(compare_version("2", ">= 1.1"))
  testthat::expect_true(compare_version("2", ">= 1.1.1"))
  testthat::expect_true(compare_version("1.2", ">= 1.1.0"))
  testthat::expect_true(compare_version("1.1.1", ">= 1.1.0.0"))

  # Hyphen-separated versions
  testthat::expect_true(compare_version("1-2-0", ">= 1-1-0"))

  # Mixed formats
  testthat::expect_true(compare_version("1.2.0", ">= 1-1-0"))
  testthat::expect_true(compare_version("1-2-0", ">= 1.1.0"))
  testthat::expect_true(compare_version("1.2-0", ">= 1-1.0"))
  testthat::expect_true(compare_version("1-2.0", ">= 1.1-0"))
})
