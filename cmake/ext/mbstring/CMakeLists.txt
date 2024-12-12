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
    libmbfl/filters/html_entities.c
    libmbfl/filters/mbfilter_7bit.c
    libmbfl/filters/mbfilter_base64.c
    libmbfl/filters/mbfilter_cjk.c
    libmbfl/filters/mbfilter_htmlent.c
    libmbfl/filters/mbfilter_qprint.c
    libmbfl/filters/mbfilter_singlebyte.c
    libmbfl/filters/mbfilter_ucs2.c
    libmbfl/filters/mbfilter_ucs4.c
    libmbfl/filters/mbfilter_utf16.c
    libmbfl/filters/mbfilter_utf32.c
    libmbfl/filters/mbfilter_utf7.c
    libmbfl/filters/mbfilter_utf7imap.c
    libmbfl/filters/mbfilter_utf8.c
    libmbfl/filters/mbfilter_uuencode.c
    libmbfl/mbfl/mbfilter_8bit.c
    libmbfl/mbfl/mbfilter_pass.c
    libmbfl/mbfl/mbfilter_wchar.c
    libmbfl/mbfl/mbfilter.c
    libmbfl/mbfl/mbfl_convert.c
    libmbfl/mbfl/mbfl_encoding.c
    libmbfl/mbfl/mbfl_filter_output.c
    libmbfl/mbfl/mbfl_language.c
    libmbfl/mbfl/mbfl_memory_device.c
    libmbfl/mbfl/mbfl_string.c
    libmbfl/nls/nls_de.c
    libmbfl/nls/nls_en.c
    libmbfl/nls/nls_hy.c
    libmbfl/nls/nls_ja.c
    libmbfl/nls/nls_kr.c
    libmbfl/nls/nls_neutral.c
    libmbfl/nls/nls_ru.c
    libmbfl/nls/nls_tr.c
    libmbfl/nls/nls_ua.c
    libmbfl/nls/nls_uni.c
    libmbfl/nls/nls_zh.c
    mb_gpc.c
    mbstring.c
    mbstring.stub.php
    php_unicode.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        libmbfl/mbfl/eaw_table.h
        libmbfl/mbfl/mbfilter_8bit.h
        libmbfl/mbfl/mbfilter_pass.h
        libmbfl/mbfl/mbfilter_wchar.h
        libmbfl/mbfl/mbfilter.h
        libmbfl/mbfl/mbfl_consts.h
        libmbfl/mbfl/mbfl_convert.h
        libmbfl/mbfl/mbfl_defs.h
        libmbfl/mbfl/mbfl_encoding.h
        libmbfl/mbfl/mbfl_filter_output.h
        libmbfl/mbfl/mbfl_language.h
        libmbfl/mbfl/mbfl_memory_device.h
        libmbfl/mbfl/mbfl_string.h
        mbstring.h
  # A separate file set so binary dir can also be created within a source dir.
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/libmbfl/config.h
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

# TODO: Fix this better. See also https://github.com/php/php-src/pull/13713
# TODO: Should status message be here?
message(STATUS "Creating ext/mbstring/libmbfl/config.h")
file(CONFIGURE OUTPUT libmbfl/config.h CONTENT [[
#ifdef _WIN32
# define HAVE_STRICMP 1
#elif defined HAVE_CONFIG_H
# include "<config.h>"
#else
# include <main/php_config.h>
#endif
]])

target_include_directories(
  php_mbstring
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libmbfl
    ${CMAKE_CURRENT_BINARY_DIR}/libmbfl
    ${CMAKE_CURRENT_SOURCE_DIR}/libmbfl/mbfl
)

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
