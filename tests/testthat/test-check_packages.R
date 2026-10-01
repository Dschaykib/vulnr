testthat::test_that("check_packages combines mocked OSV responses", {
  responses <- list(
    list(results = list(list(vulns = list(list(id = "RSEC-1"))))),
    list(
      upstream = list("CVE-1"),
      affected = list(list(ranges = list(list(events = list(
        list(), list(fixed = "1.1")
      ))))),
      severity = list(list(
        score = "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H"
      ))
    )
  )
  calls <- 0L
  testthat::local_mocked_bindings(
    api_request = function(...) {
      calls <<- calls + 1L
      if (calls == 1L) responses[[1L]] else responses[[2L]]
    },
    .package = "vulr"
  )
  result <- check_packages(data.frame(Package = "foo", Version = "1.0"))
  testthat::expect_equal(result$upstream, "CVE-1")
  testthat::expect_equal(result$severity, "CRITICAL")
  testthat::expect_equal(result$fix, "1.1")
})
