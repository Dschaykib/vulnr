# vulr - 0.0.0.9001 <img src="misc/logo.png" width=170 align="right" />

| branch        | master | dev  |
| ------------- | ------ | ---- |
| R CMD check   | [![master-branch](https://github.com/Dschaykib/newsmd/workflows/R-CMD-check-fix/badge.svg?branch=master)](https://github.com/Dschaykib/newsmd/actions?query=workflow%3AR-CMD-check-fix+branch%3Amaster) | [![dev-branch](https://github.com/Dschaykib/newsmd/workflows/R-CMD-check-fix/badge.svg?branch=dev)](https://github.com/Dschaykib/newsmd/actions?query=workflow%3AR-CMD-check-fix+branch%3Adev) |
| test coverage | [![master-test-coverage](https://img.shields.io/codecov/c/github/Dschaykib/newsmd/master.svg)](https://codecov.io/gh/Dschaykib/newsmd/branch/master) | [![dev-test-coverage](https://img.shields.io/codecov/c/github/Dschaykib/newsmd/dev.svg)](https://codecov.io/gh/Dschaykib/newsmd/branch/dev) |
| lints         | [![master-lints](https://github.com/Dschaykib/newsmd/workflows/lints/badge.svg?branch=master)](https://github.com/Dschaykib/newsmd/actions?query=workflow%3Alints+branch%3Amaster) | [![dev-lints](https://github.com/Dschaykib/newsmd/workflows/lints/badge.svg?branch=dev)](https://github.com/Dschaykib/newsmd/actions?query=workflow%3Alints+branch%3Adev) |
| CRAN | [![CRAN](https://www.r-pkg.org/badges/version/vulr)](https://cran.r-project.org/web/packages/vulr/index.html) | ![DevVersion](https://img.shields.io/badge/Version-0.0.0.9001-success) |
| vulnerabilities | - | ![vulnerabilities](https://img.shields.io/badge/vulnerabilities-0-success) |

----

Scan R project dependencies for known security vulnerabilities.

The package is currently scaffolded. The intended CI-facing API is:

```r
vulr::check()
```

By default, `check()` will inspect `renv.lock` and `DESCRIPTION`, and will
fail with an error when vulnerabilities are found. The vulnerability scanning
backend is the next implementation step.

## Installation

```r
pak::pak("your-org/vulr")
```

## TODO

[x] tests with all renv versions to get packages
[ ] get packages from DESCRIPTION
[x] get installed packages
[ ] test when no version of package is available
[x] make nice print out
[x] create functions
[ ] create tests
[x] check API rate limits -> no limits stated in the osv docs
[x] add API error handling
[ ] test other ecosystem than CRAN
[ ] include CVSS_V2, CVSS_V4, ubuntu  see: https://ossf.github.io/osv-schema/#severity-field
[x] set warning and error level based on severity, like choose a minumum severity for error and warning
[ ] check next_page_token from osv


## License

MIT
