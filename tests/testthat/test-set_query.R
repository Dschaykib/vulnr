test_that("set_query builds versioned and unversioned queries", {
  expect_equal(
    set_query("foo", "1.2"),
    list(version = "1.2", package = list(name = "foo", ecosystem = "CRAN"))
  )

  expect_false("version" %in% names(set_query("foo")))

})
