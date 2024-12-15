#[=============================================================================[
# The mbstring extension

Configure the `mbstring` extension.

This extension provides the multibyte string support.

## EXT_MBSTRING

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_MBSTRING_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## EXT_MBSTRING_MBREGEX

* Default: `ON`
* Values: `ON|OFF`

Enable multibyte regex support (requires Oniguruma).
#]=============================================================================]

project(
  PhpExtensionMbString
  LANGUAGES C
)

include(CheckSourceCompiles)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_MBSTRING "Enable the mbstring extension")

add_feature_info(
  "ext/mbstring"
  EXT_MBSTRING
  "multibyte string support"
)

cmake_dependent_option(
  EXT_MBSTRING_SHARED
  "Build the mbstring extension as a shared library"
  OFF
  "EXT_MBSTRING;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_MBSTRING_MBREGEX
  "Enable multibyte regex support (requires Oniguruma)"
  ON
  "EXT_MBSTRING"
  OFF
)

add_feature_info(
  "ext/mbstring MB regex"
  EXT_MBSTRING_MBREGEX
  "multibyte regex support"
)

if(NOT EXT_MBSTRING)
  return()
endif()

################################################################################
# Configure mbstring extension.
################################################################################

if(EXT_MBSTRING_SHARED)
  add_library(php_mbstring SHARED)
else()
  add_library(php_mbstring)
endif()

target_sources(
  php_mbstring
  PRIVATE
    mb_gpc.c
    mbstring.c
    mbstring.stub.php
    php_unicode.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        mbstring.h
)

target_compile_definitions(php_mbstring PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

# The mbstring extension doesn't seem to support interprocedural optimization
# (IPO).
set_target_properties(php_mbstring PROPERTIES INTERPROCEDURAL_OPTIMIZATION OFF)

add_dependencies(php_mbstring php_pcre)

set(HAVE_MBSTRING TRUE)

################################################################################
# Configure libmbfl.
################################################################################

set(LIBMBFL_TARGET php_mbstring)
add_subdirectory(libmbfl)

file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/libmbfl/config.h "\n" [[
#ifdef HAVE_CONFIG_H
# include <config.h>
#endif
#ifdef _WIN32
# define HAVE_STRICMP 1
# include <config.w32.h>
#else
# include <php_config.h>
#endif
]])

################################################################################
# Multibyte regex.
################################################################################

if(EXT_MBSTRING_MBREGEX)
  find_package(Oniguruma)
  set_package_properties(
    Oniguruma
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary for multibyte regex in the mbstring extension."
  )

  target_link_libraries(php_mbstring PRIVATE Oniguruma::Oniguruma)

  if(TARGET Oniguruma::Oniguruma)
    message(CHECK_START "Checking for invalid KOI8 encoding entry in Oniguruma")
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
      set(CMAKE_REQUIRED_LIBRARIES Oniguruma::Oniguruma)

      check_source_compiles(C [[
        #include <stdint.h>
        #include <oniguruma.h>

        int main(void)
        {
          return (intptr_t)(ONIG_ENCODING_KOI8 + 1);
        }
      ]] PHP_ONIG_KOI8)
    cmake_pop_check_state()
    if(PHP_ONIG_KOI8)
      message(CHECK_PASS "no")
    else()
      message(CHECK_FAIL "yes")
      set(PHP_ONIG_BAD_KOI8_ENTRY TRUE)
    endif()
  endif()

  target_compile_definitions(
    php_mbstring
    PRIVATE
      $<$<NOT:$<PLATFORM_ID:Windows>>:ONIG_ESCAPE_UCHAR_COLLISION>
      $<$<NOT:$<PLATFORM_ID:Windows>>:UChar=OnigUChar>
      # TODO: On Windows, the Oniguruma library is only usable as a static
      # library ATM, code change required to link with a DLL.
      $<$<PLATFORM_ID:Windows>:ONIG_EXTERN=extern>
  )

  target_sources(
    php_mbstring
    PRIVATE
      php_mbregex.c
    PUBLIC
      FILE_SET HEADERS
        FILES
          php_mbregex.h
          php_onig_compat.h
  )

  set(HAVE_MBREGEX TRUE)
endif()

configure_file(cmake/config.h.in config.h)
