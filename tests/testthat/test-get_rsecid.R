testthat::test_that("get_rsecid extracts OSV identifiers", {
  body <- create_body_list("foo", "1.0")
  testthat::expect_equal(
    get_rsecid(body, list(list(vulns = list(list(id = "RSEC-1")))))$id,
    "RSEC-1"
  )
  result <- get_rsecid(body, list(list()))
  testthat::expect_equal(nrow(result), 0)
  testthat::expect_named(result, c("package", "installed", "id", "fix"))
})
