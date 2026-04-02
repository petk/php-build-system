#[=============================================================================[
# The gmp extension

This extension provides GNU Multiple Precision Arithmetic support.

## Configuration options

### PHP_EXT_GMP

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.

> [!NOTE]
> When the target system is Windows, the MPIR library is used instead of GMP.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_GMP
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_GMP "Enable the gmp extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/gmp"
  PHP_EXT_GMP
  "GNU Multiple Precision Arithmetic support"
)

if(NOT PHP_EXT_GMP)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(gmp)

if(PHP_EXT_GMP STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_gmp MODULE)
else()
  add_library(php_ext_gmp OBJECT)
endif()

target_sources(
  php_ext_gmp
  PRIVATE
    gmp.c
    gmp.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_gmp_int.h
)

target_include_directories(php_ext_gmp PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(php_ext_gmp PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(package_name "MPIR")
  find_package(MPIR 2.6.0)
  set(imported_target "MPIR::MPIR")
else()
  set(package_name "GMP")
  find_package(GMP 4.2)
  set(imported_target "GMP::GMP")
endif()

set_package_properties(
  ${package_name}
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the gmp extension."
)

target_link_libraries(php_ext_gmp PUBLIC ${imported_target})

set_property(
  TARGET php_ext_gmp
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS random
)

set(HAVE_GMP TRUE)

configure_file(cmake/config.h.in config.h)
