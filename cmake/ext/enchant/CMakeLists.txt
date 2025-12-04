#[=============================================================================[
# The enchant extension

Configure the `enchant` extension.

This extension provides binding for the Enchant spelling library.

## PHP_EXT_ENCHANT

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_ENCHANT_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_ENCHANT
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_ENCHANT "Enable the enchant extension")

add_feature_info(
  "ext/enchant"
  PHP_EXT_ENCHANT
  "Enchant spelling library binding"
)

cmake_dependent_option(
  PHP_EXT_ENCHANT_SHARED
  "Build the enchant extension as a shared library"
  OFF
  PHP_EXT_ENCHANT
  OFF
)

if(NOT PHP_EXT_ENCHANT)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(enchant)

if(PHP_EXT_ENCHANT_SHARED)
  add_library(php_ext_enchant MODULE)
else()
  add_library(php_ext_enchant OBJECT)
endif()

target_sources(
  php_ext_enchant
  PRIVATE
    enchant.c
    enchant.stub.php
)

find_package(Enchant 1.4.2)
set_package_properties(
  Enchant
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the enchant extension."
)

if(TARGET Enchant::Enchant)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Enchant::Enchant)

    # The enchant_get_version() is available since 1.6.0.
    check_symbol_exists(
      enchant_get_version
      enchant.h
      PHP_EXT_ENCHANT_HAVE_ENCHANT_GET_VERSION
    )
    set(HAVE_ENCHANT_GET_VERSION ${PHP_EXT_ENCHANT_HAVE_ENCHANT_GET_VERSION})

    # The enchant_broker_set_param() is available since 1.5.0 and removed in 2.x.
    check_symbol_exists(
      enchant_broker_set_param
      enchant.h
      PHP_EXT_ENCHANT_HAVE_ENCHANT_BROKER_SET_PARAM
    )
    set(
      HAVE_ENCHANT_BROKER_SET_PARAM
      ${PHP_EXT_ENCHANT_HAVE_ENCHANT_BROKER_SET_PARAM}
    )
  cmake_pop_check_state()
endif()

target_link_libraries(php_ext_enchant PRIVATE Enchant::Enchant)

set(HAVE_ENCHANT TRUE)

configure_file(cmake/config.h.in config.h)
