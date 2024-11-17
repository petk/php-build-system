#[=============================================================================[
# The sodium extension

Configure the `sodium` extension.

This extension provides support for encryption, decryption, signatures and
password hashing.

## EXT_SODIUM

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_SODIUM_SHARED

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

option(EXT_SODIUM "Enable the sodium extension" OFF)

add_feature_info(
  "ext/sodium"
  EXT_SODIUM
  "Support for encryption, decryption, signatures and password hashing"
)

cmake_dependent_option(
  EXT_SODIUM_SHARED
  "Build the sodium extension as a shared library"
  OFF
  "EXT_SODIUM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SODIUM)
  return()
endif()

if(EXT_SODIUM_SHARED)
  add_library(php_sodium SHARED)
else()
  add_library(php_sodium)
endif()

target_sources(
  php_sodium
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

target_link_libraries(php_sodium PRIVATE Sodium::Sodium)

# Suppress some warnings on 32-bit with -Wno-type-limits and -Wno-logical-op.
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
  php_check_compiler_flag(C -Wno-type-limits HAVE_WNO_TYPE_LIMITS_C)
  if(HAVE_WNO_TYPE_LIMITS_C)
    target_compile_options(php_sodium PRIVATE -Wno-type-limits)
  endif()

  php_check_compiler_flag(C -Wno-logical-op HAVE_WNO_LOGICAL_OP_C)
  if(HAVE_WNO_LOGICAL_OP_C)
    target_compile_options(php_sodium PRIVATE -Wno-logical-op)
  endif()
endif()

set(HAVE_LIBSODIUMLIB 1)

configure_file(config.cmake.h.in config.h)
