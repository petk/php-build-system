#[=============================================================================[
PHP/Package/ZLIB

This module provides common configuration for finding the ZLIB library.
#]=============================================================================]

# Minimum required version for the zlib dependency.
set(PHP_PACKAGE_ZLIB_MIN_VERSION 1.2.11)

include_guard(GLOBAL)

include(FeatureSummary)

set_package_properties(
  ZLIB
  PROPERTIES
    URL "https://zlib.net/"
    DESCRIPTION "Compression library"
)
