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

test_that("every renv fixture version has a lockfile", {
  missing_lockfiles <- renv_fixture_versions[
    !file.exists(file.path(
      renv_fixture_root, renv_fixture_versions, "renv.lock"
    ))
  ]
  expect_true(length(missing_lockfiles) == 0L,
              info = paste("Missing renv.lock for:",
                           paste(missing_lockfiles, collapse = ", ")))
})

for (renv_version in renv_versions) {
  testthat::test_that(sprintf("parse renv %s lockfile format", renv_version), {
    lockfile <- file.path(renv_fixture_root, renv_version, "renv.lock")
    result <- parse_renv_lock(lockfile)

    expect_true(is.data.frame(result))
    expect_named(result, c("Package", "Version", "source", "path"))
    expect_true(nrow(result) > 0L)
    expect_true(all(nzchar(result$Package)))
    expect_true(all(nzchar(result$Version)))
    expect_true(all(result$source == "renv"))
    expect_true(all(result$path == lockfile))
    expect_true(any(result$Package == "renv"))
    expect_true(any(result$Version[result$Package == "renv"] == renv_version))
  })
}

test_that("parse_renv_lock handles multiple lockfiles", {
  versions <- renv_versions[c(1L, length(renv_versions))]
  lockfiles <- file.path(renv_fixture_root, versions, "renv.lock")
  result <- parse_renv_lock(lockfiles)

  expect_setequal(unique(result$path), lockfiles)
  expect_true(all(vapply(
    lockfiles, function(path) any(result$path == path), logical(1)
  )))
})

test_that("parse_renv_lock rejects a missing lockfile", {
  expect_error(parse_renv_lock("missing.lock"))
})
