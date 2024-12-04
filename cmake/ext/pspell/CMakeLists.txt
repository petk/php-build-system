#[=============================================================================[
# The pspell extension

Configure the `pspell` extension.

This extension provides spellchecking support.

## EXT_PSPELL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_PSPELL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

project(
  PhpExtensionPspell
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(EXT_PSPELL "Enable the pspell extension")

add_feature_info(
  "ext/pspell"
  EXT_PSPELL
  "spellchecking support"
)

cmake_dependent_option(
  EXT_PSPELL_SHARED
  "Build the pspell extension as a shared library"
  OFF
  "EXT_PSPELL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PSPELL)
  return()
endif()

if(EXT_PSPELL_SHARED)
  add_library(php_pspell SHARED)
else()
  add_library(php_pspell)
endif()

target_sources(
  php_pspell
  PRIVATE
    pspell.c
    pspell.stub.php
)

# Add -Wno-strict-prototypes as depends on user libs.
php_check_compiler_flag(C -Wno-strict-prototypes HAVE_WNO_STRICT_PROTOTYPES_C)
if(HAVE_WNO_STRICT_PROTOTYPES_C)
  target_compile_options(
    php_pspell
    PRIVATE
      $<$<COMPILE_LANGUAGE:C>:-Wno-strict-prototypes>
  )
endif()

find_package(Aspell 0.50.0)
set_package_properties(
  Aspell
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the pspell extension."
)

target_link_libraries(php_pspell PRIVATE Aspell::Aspell)

set(HAVE_PSPELL TRUE)

configure_file(cmake/config.h.in config.h)
