#[=============================================================================[
PHP/Package/OpenSSL

This module provides common configuration for finding the OpenSSL library.
#]=============================================================================]

# Minimum required version for the OpenSSL dependency.
set(PHP_PACKAGE_OPENSSL_MIN_VERSION 1.0.2)

include_guard(GLOBAL)

include(FeatureSummary)

set_package_properties(
  OpenSSL
  PROPERTIES
    URL "https://www.openssl.org/"
    DESCRIPTION "General-purpose cryptography and secure communication"
)
