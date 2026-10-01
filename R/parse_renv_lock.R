#' Parse package records from renv lock files
#'
#' @param renv_file Character vector of paths to `renv.lock` files.
#' @return A data frame containing package names, versions, source, and path.
#' @importFrom data.table data.table rbindlist
#' @importFrom jsonlite fromJSON
#' @keywords internal
parse_renv_lock <- function(renv_file = "renv.lock") {

  out_list <- vector(mode = "list", length = length(renv_file))

  i_file <- renv_file[1]
  for (i_id in seq_along(renv_file)) {

    i_file <- renv_file[i_id]
    stopifnot(file.exists(i_file))
    renv_info <- jsonlite::fromJSON(i_file)[["Packages"]]

    res_list <- lapply(
      X = renv_info,
      FUN = function(x) {
        data.table::data.table(
          Package = x$Package,
          Version = x$Version
        )
      }
    )

    res_dt <- data.table::rbindlist(res_list, use.names = TRUE, fill = TRUE)

    res_dt$source <- "renv"
    res_dt$path <- i_file

    out_list[[i_id]] <- res_dt

  }

  out <- data.table::rbindlist(out_list, use.names = TRUE, fill = TRUE)


  return(out)
}
