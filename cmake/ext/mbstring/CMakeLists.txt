#[=============================================================================[
# The mbstring extension

This extension provides the multibyte string support.

## Configuration options

### PHP_EXT_MBSTRING

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.

### PHP_EXT_MBSTRING_MBREGEX

* Default: `ON`
* Values: `ON|OFF`

Enables multibyte regex support (requires Oniguruma).
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_MBSTRING
  LANGUAGES C
)

include(CheckSourceCompiles)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_MBSTRING "Enable the mbstring extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/mbstring"
  PHP_EXT_MBSTRING
  "multibyte string support"
)

cmake_dependent_option(
  PHP_EXT_MBSTRING_MBREGEX
  "Enable multibyte regex support (requires Oniguruma)"
  ON
  PHP_EXT_MBSTRING
  OFF
)

add_feature_info(
  "ext/mbstring MB regex"
  PHP_EXT_MBSTRING_MBREGEX
  "multibyte regex support"
)

if(NOT PHP_EXT_MBSTRING)
  return()
endif()

################################################################################
# Configure mbstring extension.
################################################################################

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(mbstring)

if(PHP_EXT_MBSTRING STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_mbstring MODULE)
else()
  add_library(php_ext_mbstring OBJECT)
endif()

target_sources(
  php_ext_mbstring
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

target_compile_definitions(php_ext_mbstring PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

target_include_directories(php_ext_mbstring PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

# The mbstring extension doesn't seem to support interprocedural optimization
# (IPO).
set_target_properties(php_ext_mbstring PROPERTIES INTERPROCEDURAL_OPTIMIZATION OFF)

set_property(
  TARGET php_ext_mbstring
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS pcre
)

set(HAVE_MBSTRING TRUE)

################################################################################
# Configure libmbfl.
################################################################################

set(libmbfl_PROJECT_NAME "PHP_EXT_MBSTRING_LIBMBFL")
set(libmbfl_NAMESPACE "PHP")
set(libmbfl_TARGET php_ext_mbstring)
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

if(PHP_EXT_MBSTRING_MBREGEX)
  find_package(Oniguruma)
  set_package_properties(
    Oniguruma
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary for multibyte regex in the mbstring extension."
  )

  target_link_libraries(php_ext_mbstring PRIVATE Oniguruma::Oniguruma)

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
      ]] PHP_EXT_MBSTRING_ONIG_KOI8)
    cmake_pop_check_state()
    if(PHP_EXT_MBSTRING_ONIG_KOI8)
      message(CHECK_PASS "no")
    else()
      message(CHECK_FAIL "yes")
      set(PHP_ONIG_BAD_KOI8_ENTRY TRUE)
    endif()
  endif()

  target_compile_definitions(
    php_ext_mbstring
    PRIVATE
      $<$<NOT:$<PLATFORM_ID:Windows>>:ONIG_ESCAPE_UCHAR_COLLISION>
      $<$<NOT:$<PLATFORM_ID:Windows>>:UChar=OnigUChar>
      # TODO: On Windows, the Oniguruma library is only usable as a static
      # library ATM, code change required to link with a DLL.
      $<$<PLATFORM_ID:Windows>:ONIG_EXTERN=extern>
  )

  target_sources(
    php_ext_mbstring
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

################################################################################
# Provide command to generate ext/mbstring/rare_cp_bitvec.h with:
# cmake --build <build-dir> -t php_ext_mbstring_generate_codepoints
################################################################################

include(PHP/AddCommand)

php_add_command(
  php_ext_mbstring_generate_codepoints
  EXCLUDE_FROM_ALL
  ARGS
    ${CMAKE_CURRENT_SOURCE_DIR}/gen_rare_cp_bitvec.php
    ${CMAKE_CURRENT_SOURCE_DIR}/common_codepoints.txt
  OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/rare_cp_bitvec.h
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/gen_rare_cp_bitvec.php
    ${CMAKE_CURRENT_SOURCE_DIR}/common_codepoints.txt
  COMMENT "[ext/mbstring] Regenerating rare_cp_bitvec.h"
)

configure_file(cmake/config.h.in config.h)
