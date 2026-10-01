test_that("get_rsecid extracts OSV identifiers", {
  body <- create_body_list("foo", "1.0")
  expect_equal(
    get_rsecid(body, list(list(vulns = list(list(id = "RSEC-1")))) )$id,
    "RSEC-1")
  expect_equal(nrow(get_rsecid(body, list(list()))), 0)
})
