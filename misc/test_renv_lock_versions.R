
renv::install(c("pak", "callr"))

package <- "renv"
test_package <- "jsonlite"
test_package_version <- "1.8.9"

output_dir <- "renv-lockfiles"

dir.create(
  output_dir,
  recursive = TRUE,
  showWarnings = FALSE
)


# -------------------------------------------------------------------------
# Get all released renv versions from CRAN
# -------------------------------------------------------------------------

get_cran_versions <- function(package) {

  # Historical releases
  archive_url <- sprintf(
    "https://cran.r-project.org/src/contrib/Archive/%s/",
    package
  )

  archive <- readLines(archive_url, warn = FALSE)

  pattern <- sprintf(
    "%s_([0-9][^\"<]*)\\.tar\\.gz",
    package
  )

  matches <- regmatches(
    archive,
    gregexpr(pattern, archive)
  )

  files <- unique(unlist(matches))

  archive_versions <- sub(
    sprintf("^%s_(.*)\\.tar\\.gz$", package),
    "\\1",
    files
  )


  # Current CRAN release
  available <- available.packages(
    repos = "https://cloud.r-project.org"
  )

  current_version <- available[package, "Version"]


  # Combine + sort
  versions <- unique(c(
    archive_versions,
    current_version
  ))

  versions[order(package_version(versions))]
}


# -------------------------------------------------------------------------
# Create lockfile for one renv version
# -------------------------------------------------------------------------

create_lockfile <- function(
    version,
    output_dir,
    test_package,
    test_package_version
) {

  target <- file.path(output_dir, version)
  lockfile <- file.path(target, "renv.lock")

  # Makes rerunning the script cheap.
  if (file.exists(lockfile)) {
    message(
      "SKIP ",
      version,
      " (renv.lock already exists)"
    )

    return("existing")
  }

  message("")
  message("--------------------------------------------------")
  message("renv ", version)
  message("--------------------------------------------------")

  dir.create(
    target,
    recursive = TRUE,
    showWarnings = FALSE
  )

  callr::r(
    function(
    version,
    target,
    test_package,
    test_package_version
    ) {

      # ---------------------------------------------------------------
      # Isolated package library
      # ---------------------------------------------------------------

      lib <- tempfile("renv-lib-")

      dir.create(
        lib,
        recursive = TRUE
      )

      .libPaths(c(lib, .libPaths()))


      # ---------------------------------------------------------------
      # Install exact renv version
      # ---------------------------------------------------------------

      pak::pkg_install(
        paste0("renv@", version),
        lib = lib,
        ask = FALSE
      )


      # Verify that we actually loaded the requested version.
      suppressPackageStartupMessages(
        library(
          "renv",
          lib.loc = lib,
          character.only = TRUE
        )
      )

      installed_renv_version <- as.character(
        packageVersion("renv")
      )

      if (installed_renv_version != version) {
        stop(
          "Expected renv ",
          version,
          " but loaded ",
          installed_renv_version
        )
      }

      # ---------------------------------------------------------------
      # Create a small R file referencing the package
      #
      # This is important because renv's dependency discovery needs to
      # see that the project actually uses the package.
      # ---------------------------------------------------------------

      r_file <- file.path(
        target,
        "dependency.R"
      )

      writeLines(
        sprintf(
          "%s::toJSON(list(test = TRUE))",
          test_package
        ),
        r_file
      )

      # ---------------------------------------------------------------
      # Install the SAME package/version for every fixture
      # ---------------------------------------------------------------

      # renv::install(
      #   paste0(
      #     test_package,
      #     "@",
      #     test_package_version
      #   ),
      #   library = lib,
      #   prompt = FALSE
      # )


      # ---------------------------------------------------------------
      # Initialize project
      # ---------------------------------------------------------------

      renv::init(
        project = target,
        bare = FALSE
      )



      # ---------------------------------------------------------------
      # Snapshot
      # ---------------------------------------------------------------

      renv::snapshot(
        project = target,
        prompt = FALSE
      )
    },
    args = list(
      version = version,
      target = normalizePath(target),
      test_package = test_package,
      test_package_version = test_package_version
    ),
    show = TRUE
  )


  # -------------------------------------------------------------------
  # Verify output
  # -------------------------------------------------------------------

  if (!file.exists(lockfile)) {
    stop(
      "renv ",
      version,
      " completed but no renv.lock was created"
    )
  }

  "success"
}


# -------------------------------------------------------------------------
# Get all renv versions
# -------------------------------------------------------------------------

versions <- get_cran_versions(package)

message("")
message(
  "Found ",
  length(versions),
  " renv releases."
)

print(versions)


# -------------------------------------------------------------------------
# Generate fixtures
# -------------------------------------------------------------------------




test_renv <- function(version) {

  tryCatch(
    {

      status <- create_lockfile(
        version = version,
        output_dir = output_dir,
        test_package = test_package,
        test_package_version = test_package_version
      )

      data.frame(
        renv_version = version,
        status = status,
        error = NA_character_
      )

    },
    error = function(e) {

      message("")
      message(
        "SKIPPING renv ",
        version
      )

      message(
        "Reason: ",
        conditionMessage(e)
      )

      # Remove incomplete fixture directory.
      target <- file.path(
        output_dir,
        version
      )

      if (dir.exists(target)) {
        unlink(
          target,
          recursive = TRUE,
          force = TRUE
        )
      }

      data.frame(
        renv_version = version,
        status = "skipped",
        error = conditionMessage(e)
      )
    }
  )
}
#unlink("renv-lockfiles/1.0.5/", recursive = TRUE)
#test_renv(versions[37])
results <- lapply(versions, test_renv)


# -------------------------------------------------------------------------
# Write summary
# -------------------------------------------------------------------------

results_all <- do.call(
  rbind,
  results
)

results_file <- file.path(
  output_dir,
  "results.csv"
)

write.csv(
  results_all,
  results_file,
  row.names = FALSE
)


# -------------------------------------------------------------------------
# Summary
# -------------------------------------------------------------------------

message("")
message("==================================================")
message("Finished")
message("==================================================")

message(
  "Successful: ",
  sum(results_all$status %in% c("success", "existing"))
)

message(
  "Skipped:    ",
  sum(results_all$status == "skipped")
)

message("")
message(
  "Results written to: ",
  results_file
)

print(results_all)


#  loading packages -------------------------------------------------------


versions


tmp_res_list <- vector(mode = "list", length = length(versions))
i_version <- 1
for (i_version in seq_along(versions)) {

  if (file.exists(paste0("renv-lockfiles/", versions[i_version], "/renv.lock"))) {
    cat(versions[i_version], "\n")
  } else {
    cat(versions[i_version], "skipped\n")
    next()
  }

  tmp_res_list[[i_version]] <- rosv:::parse_renv_lock(
    dir = paste0("renv-lockfiles/", versions[i_version]),
    as.data.frame = FALSE
  )
}

