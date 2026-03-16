#[=============================================================================[
PHP/Package/EXPAT

This module provides common configuration for finding the EXPAT library.
#]=============================================================================]

include_guard(GLOBAL)

include(FeatureSummary)

set_package_properties(
  EXPAT
  PROPERTIES
    URL "https://libexpat.github.io/"
    DESCRIPTION "Stream-oriented XML parser library"
)
