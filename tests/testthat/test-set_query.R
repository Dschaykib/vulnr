testthat::test_that("set_query builds versioned and unversioned queries", {
  testthat::expect_equal(
    set_query("foo", "1.2"),
    list(version = "1.2", package = list(name = "foo", ecosystem = "CRAN"))
  )

  testthat::expect_false("version" %in% names(set_query("foo")))
  testthat::expect_false("version" %in% names(set_query("foo", NA)))
  testthat::expect_false("version" %in% names(set_query("foo", "")))

})
