test_that("get_severity calculates severity from a mocked CVSS vector", {
  local_mocked_bindings(
    api_request = function(...) {
      list(severity = list(list(
        score = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H"
      )))
      },
    .package = "vulr"
    )

  result <- get_severity("CVE-1")
  expect_equal(result$score, 9.8)
  expect_equal(result$severity, "CRITICAL")
})
