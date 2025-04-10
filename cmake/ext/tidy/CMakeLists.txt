#[=============================================================================[
# The tidy extension

Configure the `tidy` extension.

This extension provides support for Tidy HTML utility support to handle HTML,
XHTML and XML documents.

## PHP_EXT_TIDY

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_TIDY_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.25...3.31)

project(
  PhpExtensionTidy
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(PHP_EXT_TIDY "Enable the tidy extension")

add_feature_info(
  "ext/tidy"
  PHP_EXT_TIDY
  "HTML, XHTML and XML correction support"
)

cmake_dependent_option(
  PHP_EXT_TIDY_SHARED
  "Build the tidy extension as a shared library"
  OFF
  "PHP_EXT_TIDY;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_TIDY)
  return()
endif()

if(PHP_EXT_TIDY_SHARED)
  add_library(php_ext_tidy SHARED)
else()
  add_library(php_ext_tidy)
endif()

target_sources(
  php_ext_tidy
  PRIVATE
    php_tidy.def
    tidy.c
    tidy.stub.php
)

# Add -Wno-ignored-qualifiers as this is an issue upstream. Fixed in tidy-html5
# 5.7.20. See: https://github.com/htacg/tidy-html5/issues/866
if(Tidy_VERSION VERSION_LESS 5.7.20)
  php_check_compiler_flag(
    C
    -Wno-ignored-qualifiers
    HAVE_WNO_IGNORED_QUALIFIERS_C
  )
  if(HAVE_WNO_IGNORED_QUALIFIERS_C)
    target_compile_options(php_ext_tidy PRIVATE -Wno-ignored-qualifiers)
  endif()
endif()

target_compile_definitions(php_ext_tidy PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(Tidy)
set_package_properties(
  Tidy
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the tidy extension."
)

target_link_libraries(php_ext_tidy PRIVATE Tidy::Tidy)

if(TARGET Tidy::Tidy)
  check_library_exists(Tidy::Tidy tidyOptGetDoc "" HAVE_TIDYOPTGETDOC)
  check_library_exists(Tidy::Tidy tidyReleaseDate "" HAVE_TIDYRELEASEDATE)
endif()

set(HAVE_TIDY TRUE)

configure_file(cmake/config.h.in config.h)
