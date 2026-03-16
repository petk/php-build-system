#[=============================================================================[
PHP/Package/SQLite3

This module provides common configuration for finding the SQLite3 library.
#]=============================================================================]

# Minimum required version for the SQLite dependency.
set(PHP_PACKAGE_SQLITE3_MIN_VERSION 3.7.17)

include_guard(GLOBAL)

include(FeatureSummary)

set_package_properties(
  SQLite3
  PROPERTIES
    URL "https://www.sqlite.org/"
    DESCRIPTION "SQL database engine library"
)
