#' Format vulnerability findings for display
#'
#' @param x Data frame containing vulnerability findings.
#' @param group Logical; group findings by package when `TRUE`.
#' @param refs Character vector of source paths referenced by the findings.
#' @return A list with `summary` and `details` strings, or a single clean-result
#'   string when there are no findings.
#' @keywords internal
format_vulnerabilities <- function(x = NULL, group = TRUE, refs = c()) {
  stopifnot(is.data.frame(x) || is.null(x))
  stopifnot(is.logical(group), length(group) == 1L, !is.na(group))

  if (is.null(x) || nrow(x) == 0L) {
    return("✔ No known vulnerabilities found.")
  }

  severity_order <- c(
    "CRITICAL" = 4L,
    "HIGH"     = 3L,
    "MEDIUM"   = 2L,
    "LOW"      = 1L
  )

  # Sort by package, then severity and score
  x <- x[
    order(
      x$package,
      -unname(severity_order[x$severity]),
      -x$score
    ),
  ]

  n_vulns <- nrow(x)
  n_packages <- length(unique(x$package))

  # Header
  header <- sprintf(
    "✖ Found %d vulnerabilit%s in %d package%s",
    n_vulns,
    if (n_vulns == 1L) "y" else "ies",
    n_packages,
    if (n_packages == 1L) "" else "s"
  )

  # Severity summary
  severity_levels <- c("CRITICAL", "HIGH", "MEDIUM", "LOW")

  severity_counts <- table(
    factor(x$severity, levels = severity_levels)
  )

  info <- sprintf(
    paste0(
      "  %-8s %d\n",
      "  %-8s %d\n",
      "  %-8s %d\n",
      "  %-8s %d"
    ),
    "CRITICAL", severity_counts["CRITICAL"],
    "HIGH",     severity_counts["HIGH"],
    "MEDIUM",   severity_counts["MEDIUM"],
    "LOW",      severity_counts["LOW"]
  )

  references <- paste0(
    c("References:\n",
      paste0(
        "[", seq_along(refs), "] ", refs,
        sep = "\n"
      )),
    collapse = ""
  )

  # Pre-format values
  severity <- toupper(x$severity)
  score <- sprintf("(%g)", x$score)

  fix <- ifelse(
    x$fix == "no fix available",
    "no fix available",
    paste0("fix >= ", x$fix)
  )

  path_ref <- x$ref

  # Calculate global column widths
  widths <- list(
    severity = max(nchar(c("Severity", severity))),
    package  = max(nchar(c("Package", x$package))),
    version  = max(nchar(c("Version", x$installed))),
    upstream = max(nchar(c("Upstream", x$upstream))),
    score    = max(nchar(c("Score", score))),
    fix      = max(nchar(c("Fix", fix))),
    reference = max(nchar(c("Reference", path_ref)))
  )

  if (group) {
    # Group vulnerabilities by package
    packages <- unique(x$package)

    blocks <- vapply(packages, function(pkg) {
      idx <- which(x$package == pkg)

      findings <- vapply(idx, function(i) {
        sprintf(
          "  %-*s  %-*s  %*s  %s  %s",
          widths$severity,
          severity[i],
          widths$upstream,
          x$upstream[i],
          widths$score,
          score[i],
          sprintf("%-*s", widths$fix, fix[i]),
          sprintf("%-*s", widths$reference, path_ref[i])
        )
      }, character(1))

      cve_header <- sprintf(
        "  %-*s  %-*s  %*s  %s  %s",
        widths$severity,
        "Severity",
        widths$upstream,
        "Upstream",
        widths$score,
        "Score",
        sprintf("%-*s", widths$fix, "Fix"),
        sprintf("%-*s", widths$reference, "Reference")
      )

      pkg_version <- x$installed[idx[1]]
      if (is.na(pkg_version)) {
        pkg_version <- ""
      }

      paste(
        sprintf("%s %s", pkg, pkg_version),
        paste(c(cve_header, findings), collapse = "\n"),
        sep = "\n"
      )
    }, character(1))


    cve_block <- paste(blocks, collapse = "\n\n")


  }

  if (!group) {
    # Flat output
    cve_header <- sprintf(
      "  %-*s  %-*s  %-*s  %-*s  %*s  %-*s  %-*s",
      widths$severity,
      "Severity",
      widths$package,
      "Package",
      widths$version,
      "Version",
      widths$upstream,
      "Upstream",
      widths$score,
      "Score",
      widths$fix,
      "Fix",
      widths$reference,
      "Reference"
    )

    rows <- vapply(seq_len(nrow(x)), function(i) {
      sprintf(
        "  %-*s  %-*s  %-*s  %-*s  %*s  %-*s  %-*s",
        widths$severity,
        severity[i],
        widths$package,
        x$package[i],
        widths$version,
        x$installed[i],
        widths$upstream,
        x$upstream[i],
        widths$score,
        score[i],
        widths$fix,
        fix[i],
        widths$reference,
        path_ref[i]
      )
    }, character(1))
    cve_block <- paste(c(cve_header, rows), collapse = "\n")
  }

  out <- list(
    summary = paste0(
      header,
      "\n",
      info),
    details = paste0(
      cve_block,
      "\n\n",
      references
    )
  )

  return(out)
}
