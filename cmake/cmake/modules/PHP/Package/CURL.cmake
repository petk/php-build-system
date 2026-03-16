#[=============================================================================[
PHP/Package/CURL

This module provides common configuration for finding the CURL library.
#]=============================================================================]

include_guard(GLOBAL)

include(FeatureSummary)

set_package_properties(
  CURL
  PROPERTIES
    URL "https://curl.se/"
    DESCRIPTION "Library for transferring data with URLs"
)
