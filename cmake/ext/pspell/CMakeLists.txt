#[=============================================================================[
# The pspell extension

Configure the `pspell` extension.

This extension provides spellchecking support.

## PHP_EXT_PSPELL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PSPELL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.27...4.0)

project(
  PhpExtensionPspell
  LANGUAGES C
)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(PHP_EXT_PSPELL "Enable the pspell extension")

add_feature_info(
  "ext/pspell"
  PHP_EXT_PSPELL
  "spellchecking support"
)

cmake_dependent_option(
  PHP_EXT_PSPELL_SHARED
  "Build the pspell extension as a shared library"
  OFF
  "PHP_EXT_PSPELL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_PSPELL)
  return()
endif()

if(PHP_EXT_PSPELL_SHARED)
  add_library(php_ext_pspell SHARED)
else()
  add_library(php_ext_pspell)
endif()

target_sources(
  php_ext_pspell
  PRIVATE
    pspell.c
    pspell.stub.php
)

# Add -Wno-strict-prototypes as depends on user libs.
php_check_compiler_flag(C -Wno-strict-prototypes _PHP_HAVE_WNO_STRICT_PROTOTYPES)
if(_PHP_HAVE_WNO_STRICT_PROTOTYPES)
  target_compile_options(
    php_ext_pspell
    PRIVATE
      $<$<COMPILE_LANGUAGE:C>:-Wno-strict-prototypes>
  )
endif()

find_package(ASPELL 0.50.0 COMPONENTS ASPELL OPTIONAL_COMPONENTS Executable)
set_package_properties(
  ASPELL
  PROPERTIES
    TYPE REQUIRED
    URL "http://aspell.net/"
    DESCRIPTION "GNU Aspell spell checker library"
    PURPOSE "Necessary to enable the pspell extension."
)

if(
  CMAKE_VERSION VERSION_LESS 4.1
  AND ASPELL_FOUND
  AND NOT TARGET ASPELL::ASPELL
)
  add_library(ASPELL::ASPELL INTERFACE IMPORTED)
  set_target_properties(
    ASPELL::ASPELL
    PROPERTIES
      INTERFACE_LINK_LIBRARIES "${ASPELL_LIBRARIES}"
      INTERFACE_INCLUDE_DIRECTORIES "${ASPELL_INCLUDE_DIR}"
  )
endif()

# Sanity check for Aspell minimum version.
if(TARGET ASPELL::ASPELL)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ASPELL::ASPELL)
    check_symbol_exists(new_aspell_config aspell.h PHP_EXT_PSPELL_SANITY_CHECK)
  cmake_pop_check_state()

  if(NOT PHP_EXT_PSPELL_SANITY_CHECK)
    message(
      FATAL_ERROR
      "Aspell sanity check failed: new_aspell_config() not found in aspell.h. "
      "Please, install libaspell 0.50 or later and check if it is correctly "
      "installed."
    )
  endif()
endif()

target_link_libraries(php_ext_pspell PRIVATE ASPELL::ASPELL)

set(HAVE_PSPELL TRUE)

configure_file(cmake/config.h.in config.h)
