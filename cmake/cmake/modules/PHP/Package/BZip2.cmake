#[=============================================================================[
PHP/Package/BZip2

This module provides common configuration for finding the BZip2 library.
#]=============================================================================]

include_guard(GLOBAL)

include(FeatureSummary)

set_package_properties(
  BZip2
  PROPERTIES
    URL "https://sourceware.org/bzip2/"
    DESCRIPTION "Block-sorting file compressor library"
)
