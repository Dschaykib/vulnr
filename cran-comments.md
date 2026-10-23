# Initial submission notes

This is a new package that scans R package dependencies for known security 
vulnerabilities using the OSV database.

## Test environments

* local MacOS Tahoe 26.6, R 4.5.1
* tested with GitHub actions for R 4.5, R 4.6 on
  - Ubuntu latest (24.04.5)
  - macOS latest (26.6.2)
  - Windows latest (Microsoft Windows Server 2025, 10.0.26100)
* tested with rhub Github actions for R-devel on
  - linux
  - m1-san
  - macos
  - macos-arm64
  - windows

## R CMD check results

❯ checking for future file timestamps ... NOTE
  unable to verify current time

0 errors ✔ | 0 warnings ✔ | 1 note ✖

