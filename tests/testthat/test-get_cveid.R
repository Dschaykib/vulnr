testthat::test_that("get_cveid extracts upstream IDs and fixed versions", {
  response <- list(
    upstream = list("CVE-1"),
    affected = list(
      list(
        ranges = list(
          list(
            events = list(
              list(),
              list(fixed = "1.1")
            )
          )
        )
      )
    )
  )
  testthat::local_mocked_bindings(
    api_request = function(...) response,
    .package = "vulr"
  )
  input <- data.table::data.table(
    package = "foo", installed = "1.0", id = "RSEC-1"
  )
  result <- get_cveid(input)
  testthat::expect_equal(result$upstream, "CVE-1")
  testthat::expect_equal(result$fix, "1.1")

  empty_result <- get_cveid(data.table::data.table(
    package = character(), installed = character(), id = character(),
    fix = character()
  ))
  testthat::expect_equal(nrow(empty_result), 0)
  testthat::expect_named(
    empty_result, c("package", "installed", "id", "upstream", "fix")
  )
})
