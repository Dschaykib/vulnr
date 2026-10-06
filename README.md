# vulnr - 0.0.2 <img src="misc/logo.png" width=170 align="right" />

| branch        | master | dev  |
| ------------- | ------ | ---- |
| R CMD check   | [![master-branch](https://github.com/Dschaykib/vulnr/workflows/R-CMD-check-fix/badge.svg?branch=master)](https://github.com/Dschaykib/vulnr/actions?query=workflow%3AR-CMD-check-fix+branch%3Amaster) | [![dev-branch](https://github.com/Dschaykib/vulnr/workflows/R-CMD-check-fix/badge.svg?branch=dev)](https://github.com/Dschaykib/vulnr/actions?query=workflow%3AR-CMD-check-fix+branch%3Adev) |
| test coverage | [![master-test-coverage](https://img.shields.io/codecov/c/github/Dschaykib/vulnr/master.svg)](https://codecov.io/gh/Dschaykib/vulnr/branch/master) | [![dev-test-coverage](https://img.shields.io/codecov/c/github/Dschaykib/vulnr/dev.svg)](https://codecov.io/gh/Dschaykib/vulnr/branch/dev) |
| lints         | [![master-lints](https://github.com/Dschaykib/vulnr/workflows/lints/badge.svg?branch=master)](https://github.com/Dschaykib/vulnr/actions?query=workflow%3Alints+branch%3Amaster) | [![dev-lints](https://github.com/Dschaykib/vulnr/workflows/lints/badge.svg?branch=dev)](https://github.com/Dschaykib/vulnr/actions?query=workflow%3Alints+branch%3Adev) |
| vulnerabilities | - | ![vulnerabilities](https://img.shields.io/badge/vulnerabilities-1-red) |

----

Scan R project dependencies for known security vulnerabilities.


## Installation

```r
devtools::install_github("Dschaykib/vulnr")
library(vulnr)
```

## Usage of `vulnr`

By default, `check()` inspects `renv.lock` and installed libraries, then queries
the [OSV database](https://osv.dev/list?q=&ecosystem=CRAN).
You can also provide package names and optional versions directly.
Missing versions (`NA` or `""`) are treated as unversioned queries.

```r
vulnr::check(data = c("dplyr", "httr"))

vulnr::check(data = data.frame(
  Package = c("dplyr", "httr"),
  Version = c("1.1.4", NA_character_)
))
```


## Output

`check()` prints a detailed report and a summary when vulnerabilities are
found. The report is a `message()` and the summary can be a `warning()` or
an `error()` depending on the settings. By default, findings are grouped
by package. The following is an illustrative example (the identifiers and
versions are placeholders):

```text
example 1.0.0
  Severity  Upstream       Score  Fix               Reference
  CRITICAL  CVE-2026-1234  (9.8)  fix >= 1.0.1       [1]
  HIGH      CVE-2026-5678  (7.5)  no fix available   [1]

References:
[1]
data
```

```text
Found 2 vulnerabilities in 1 package
  CRITICAL 1
  HIGH     1
  MEDIUM   0
  LOW      0
```

The report means that two known vulnerabilities were found in the installed
`example` package. `Upstream` is the vulnerability identifier returned by the
[OSV database](https://osv.dev/). `Score` is the CVSS 3.1 base score on a scale
from 0.0 to 10.0; `Severity` is derived from that score. In CVSS 3.1, scores
of 0.0, 0.1–3.9, 4.0–6.9, 7.0–8.9, and 9.0–10.0 correspond to None, Low,
Medium, High, and Critical respectively. See the [FIRST CVSS v3.1
specification](https://www.first.org/cvss/v3.1/specification-document) for the
scoring model and severity ranges.

`Fix` shows the first package version known to contain a fix, when OSV provides
one. `Reference` points to the input source listed at the bottom of the
report; `[1]` means that this finding came from the first source (for example,
the `renv.lock` file). If no vulnerabilities are found, `check()` prints
`No known vulnerabilities found.`

By default, `error_level = "LOW"`, so any Low, Medium, High, or Critical
finding causes `check()` to stop with an error after printing the report. Set a
higher threshold such as `error_level = "HIGH"` if only High and Critical
findings should fail the check. Use `return_cves = TRUE` to receive the
underlying vulnerability data table instead of the formatted report.


# TODO explain csv result without error more


## Open Topics

- [x] create functions
- [x] create tests
- [x] tests with all renv versions to get packages
- [x] get installed packages
- [x] test when no version of package is available
- [x] make nice print out
- [x] check API rate limits -> no limits stated in the OSV docs
- [x] add API error handling
- [x] set warning and error level based on severity, like choose a minimum severity for error and warning
- [ ] test other ecosystem than CRAN
- [ ] include CVSS_V2, CVSS_V4, ubuntu  see: https://ossf.github.io/osv-schema/#severity-field
- [ ] check next_page_token from osv
- [ ] tackle todo notes in code
- [ ] fix workflows with correct R versions for dependencies or adjust dependencies


## License

MIT

