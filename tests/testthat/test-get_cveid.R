test_that("get_cveid extracts upstream IDs and fixed versions", {
  response <- list(
    upstream = list("CVE-1"),
    affected = list(
      list(
        ranges = list(
          list(
            events = list(
              list(),
              list(
                fixed = "1.1")
              )
            )
          )
        )
      )
    )
  local_mocked_bindings(api_request = function(...) response, .package = "vulr")
  input <- data.table::data.table(
    package = "foo", installed = "1.0", id = "RSEC-1"
  )
  result <- get_cveid(input)
  expect_equal(result$upstream, "CVE-1")
  expect_equal(result$fix, "1.1")
})
