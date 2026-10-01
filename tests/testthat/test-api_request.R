test_that("api_request validates its HTTP verb", {
  expect_error(
    api_request("https://example.invalid", verb = "PATCH"),
    "should be one of"
  )
})
