#[=============================================================================[
PHP/Package/LibXslt

This module provides common configuration for finding the XSLT library.
#]=============================================================================]

# Minimum required version for the LibXslt dependency.
set(PHP_PACKAGE_LIBXSLT_MIN_VERSION 1.1.0)

include(FeatureSummary)

set_package_properties(
  LibXslt
  PROPERTIES
    URL "https://gitlab.gnome.org/GNOME/libxslt"
    DESCRIPTION "XSLT processor library"
)
