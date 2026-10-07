testthat::test_that("it appends dependencies without duplicates", {
  data <- data.frame(
    Package = "foo", Version = "1.0.0", source = "data", path = "input"
  )
  check_dt <- data.table::data.table(
    Package = c("foo", "bar", "baz"),
    Version = c("1.0.0", NA, NA),
    source = c("data", "dependency", "dependency"),
    path = c("input", "dependency of foo", "dependency of foo")
  )

  testthat::local_mocked_bindings(
    package_dependencies = function(...) list(foo = c("bar", "baz")),
    .package = "tools"
  )

  result <- add_dependencies(data)

  testthat::expect_equal(result, check_dt)

})

testthat::test_that("it does not append already present packages", {
  data <- data.frame(
    Package = c("foo", "bar"),
    Version = c("1.0.0", "1.0.0"),
    source = c("data", "data"),
    path = c("input", "input")
  )
  check_dt <- data.table::data.table(
    Package = c("foo", "bar"),
    Version = c("1.0.0", "1.0.0"),
    source = c("data", "data"),
    path = c("input", "input")
  )

  testthat::local_mocked_bindings(
    package_dependencies = function(...) list(foo = "bar", bar = character()),
    .package = "tools"
  )

  result <- add_dependencies(data)
  testthat::expect_equal(result, check_dt)

})
