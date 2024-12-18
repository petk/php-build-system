#[=============================================================================[
# The sodium extension

Configure the `sodium` extension.

This extension provides support for encryption, decryption, signatures and
password hashing.

## PHP_EXT_SODIUM

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SODIUM_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionSodium
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(PHP_EXT_SODIUM "Enable the sodium extension")

add_feature_info(
  "ext/sodium"
  PHP_EXT_SODIUM
  "encryption, decryption, signatures and password hashing"
)

cmake_dependent_option(
  PHP_EXT_SODIUM_SHARED
  "Build the sodium extension as a shared library"
  OFF
  "PHP_EXT_SODIUM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_SODIUM)
  return()
endif()

if(PHP_EXT_SODIUM_SHARED)
  add_library(php_ext_sodium SHARED)
else()
  add_library(php_ext_sodium)
endif()

target_sources(
  php_ext_sodium
  PRIVATE
    libsodium.c
    libsodium.stub.php
    sodium_pwhash.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_libsodium.h
)

find_package(Sodium 1.0.8)
set_package_properties(
  Sodium
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the sodium extension."
)

target_link_libraries(php_ext_sodium PRIVATE Sodium::Sodium)

# Suppress some warnings on 32-bit with -Wno-type-limits and -Wno-logical-op.
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
  php_check_compiler_flag(C -Wno-type-limits HAVE_WNO_TYPE_LIMITS_C)
  if(HAVE_WNO_TYPE_LIMITS_C)
    target_compile_options(php_ext_sodium PRIVATE -Wno-type-limits)
  endif()

  php_check_compiler_flag(C -Wno-logical-op HAVE_WNO_LOGICAL_OP_C)
  if(HAVE_WNO_LOGICAL_OP_C)
    target_compile_options(php_ext_sodium PRIVATE -Wno-logical-op)
  endif()
endif()

set(HAVE_LIBSODIUMLIB TRUE)

configure_file(cmake/config.h.in config.h)
