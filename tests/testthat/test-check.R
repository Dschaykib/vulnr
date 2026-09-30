test_that("scan returns the expected result structure", {
  result <- scan(
    renv_lock = tempfile(),
    description = tempfile()
  )

  expect_named(result, c("renv", "description"))
  expect_length(result$renv, 0)
  expect_length(result$description, 0)
})

test_that("check returns clean results without failing", {
  expect_equal(
    check(
      renv_lock = tempfile(),
      description = tempfile()
    ),
    list(renv = list(), description = list())
  )
})
