#[=============================================================================[
PHP/Package/OpenSSL

This module provides common configuration for finding the PostgreSQL library.
#]=============================================================================]

# Minimum required version for the PostgreSQL dependency.
set(PHP_PACKAGE_POSTGRESQL_MIN_VERSION 10.0)

include_guard(GLOBAL)

include(FeatureSummary)

set_package_properties(
  PostgreSQL
  PROPERTIES
    URL "https://www.postgresql.org/"
    DESCRIPTION "PostgreSQL database library"
)
