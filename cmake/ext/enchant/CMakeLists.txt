#[=============================================================================[
# The enchant extension

Configure the `enchant` extension.

This extension provides binding for the Enchant spelling library.

## EXT_ENCHANT

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_ENCHANT_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionEnchant
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_ENCHANT "Enable the enchant extension")

add_feature_info(
  "ext/enchant"
  EXT_ENCHANT
  "Enchant spelling library binding"
)

cmake_dependent_option(
  EXT_ENCHANT_SHARED
  "Build the enchant extension as a shared library"
  OFF
  "EXT_ENCHANT;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ENCHANT)
  return()
endif()

if(EXT_ENCHANT_SHARED)
  add_library(php_enchant SHARED)
else()
  add_library(php_enchant)
endif()

target_sources(
  php_enchant
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
  # The enchant_get_version() is available since 1.6.0.
  check_library_exists(
    Enchant::Enchant
    enchant_get_version
    ""
    HAVE_ENCHANT_GET_VERSION
  )

  # The enchant_broker_set_param() is available since 1.5.0 and removed in 2.x.
  check_library_exists(
    Enchant::Enchant
    enchant_broker_set_param
    ""
    HAVE_ENCHANT_BROKER_SET_PARAM
  )
endif()

target_link_libraries(php_enchant PRIVATE Enchant::Enchant)

set(HAVE_ENCHANT TRUE)

configure_file(config.cmake.h.in config.h)
