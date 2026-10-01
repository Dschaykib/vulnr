renv_fixture_root <- testthat::test_path("..", "..", "renv-lockfiles")
renv_fixture_versions <- list.dirs(
  renv_fixture_root, full.names = FALSE, recursive = FALSE
)
renv_fixture_versions <- renv_fixture_versions[
  grepl("^[0-9]+\\.[0-9]+\\.[0-9]+$", renv_fixture_versions)
]
renv_versions <- renv_fixture_versions[
  file.exists(file.path(renv_fixture_root, renv_fixture_versions, "renv.lock"))
]

for (renv_version in renv_fixture_versions) {
  testthat::test_that(sprintf("parse renv %s lockfile format", renv_version), {

    testthat::skip_if_not(
      renv_version %in% renv_versions,
      message = paste("Missing renv.lock for", renv_version)
    )

    lockfile <- file.path(renv_fixture_root, renv_version, "renv.lock")
    result <- parse_renv_lock(lockfile)

    testthat::expect_true(is.data.frame(result))
    testthat::expect_named(result, c("Package", "Version", "source", "path"))
    testthat::expect_true(nrow(result) > 0L)
    testthat::expect_true(all(nzchar(result$Package)))
    testthat::expect_true(all(nzchar(result$Version)))
    testthat::expect_true(all(result$source == "renv"))
    testthat::expect_true(all(result$path == lockfile))
    testthat::expect_true(any(result$Package == "renv"))
    testthat::expect_true(
      any(result$Version[result$Package == "renv"] == renv_version)
    )
  })
}

testthat::test_that("parse_renv_lock handles multiple lockfiles", {
  versions <- renv_versions[c(1L, length(renv_versions))]
  lockfiles <- file.path(renv_fixture_root, versions, "renv.lock")

  testthat::skip_if_not(all(file.exists(lockfiles)))
  result <- parse_renv_lock(lockfiles)

  testthat::expect_setequal(unique(result$path), lockfiles)
  testthat::expect_true(all(vapply(
    lockfiles, function(path) any(result$path == path), logical(1)
  )))
})

testthat::test_that("parse_renv_lock rejects a missing lockfile", {
  testthat::expect_error(parse_renv_lock("missing.lock"))
})
