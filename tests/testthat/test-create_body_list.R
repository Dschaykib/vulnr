testthat::test_that("create_body_list builds OSV queries", {
  testthat::expect_equal(
    create_body_list(c("foo", "bar"), c("1", "2"))$queries[[1]]$version,
    "1"
  )
  testthat::expect_null(create_body_list())
  testthat::expect_error(create_body_list("foo", c("1", "2")), "same length")


  create_body_list(c("foo", "bar"), c(NA_character_, ""))

})
