testthat::test_that("create_body_list builds OSV queries", {

  test_res <- create_body_list(
    pkg = c("foo", "bar"),
    version = c("1", "2")
  )
  res <- list(
    queries = list(
      list(
        version = "1",
        package = list(name = "foo", ecosystem = "CRAN")
      ),
      list(
        version = "2",
        package = list(name = "bar", ecosystem = "CRAN")
      )
    )
  )

  testthat::expect_equal(test_res, res)

})

testthat::test_that("create_body_list handles missing version", {

  res <- list(
    queries = list(
      list(
        package = list(name = "foo", ecosystem = "CRAN")
      ),
      list(
        package = list(name = "bar", ecosystem = "CRAN")
      )
    )
  )

  test_res_1 <- create_body_list(
    pkg = c("foo", "bar"),
    version = c(NA_character_, "")
  )
  testthat::expect_equal(test_res_1, res)

  test_res_2 <- create_body_list(
    pkg = c("foo", "bar"),
    version = NULL
  )
  testthat::expect_equal(test_res_2, res)

  test_res_3 <- create_body_list(
    pkg = c("foo", "bar"),
    version = c()
  )
  testthat::expect_equal(test_res_3, res)

})


testthat::test_that("create_body_list handles missing pkg", {

  testthat::expect_error(
    create_body_list(pkg = c("foo", "bar", NA_character_, "")),
    "contain missing or empty values"
  )
  testthat::expect_error(
    create_body_list(pkg = c(NA_character_, "")),
    "contain missing or empty values"
  )
  testthat::expect_error(
    create_body_list(pkg = c(NA_character_)),
    "contain missing or empty values"
  )

})


testthat::test_that("create_body_list handles empty input gracefully", {
  testthat::expect_null(create_body_list())
})


testthat::test_that("create_body_list handles different lengths inputs", {

  testthat::expect_error(
    create_body_list(pkg = "foo", version = c("1", "2")),
    "same length"
  )

  testthat::expect_error(
    create_body_list(pkg = c("foo", "bar"), version = c("1")),
    "same length"
  )


})
