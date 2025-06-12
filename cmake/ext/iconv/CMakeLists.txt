#[=============================================================================[
# The iconv extension

Configure the `iconv` extension.

This extension provides support for interface to iconv character set conversion
facility.

## PHP_EXT_ICONV

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_ICONV_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.27...4.0)

project(
  PhpExtensionIconv
  LANGUAGES C
)

include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_ICONV "Enable the iconv extension" ON)

add_feature_info(
  "ext/iconv"
  PHP_EXT_ICONV
  "internationalization conversion interface"
)

cmake_dependent_option(
  PHP_EXT_ICONV_SHARED
  "Build the iconv extension as a shared library"
  OFF
  "PHP_EXT_ICONV;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_ICONV)
  return()
endif()

if(PHP_EXT_ICONV_SHARED)
  add_library(php_ext_iconv SHARED)
else()
  add_library(php_ext_iconv)
endif()

target_sources(
  php_ext_iconv
  PRIVATE
    iconv.c
    iconv.stub.php
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:php_iconv.def>
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_iconv.h
)

target_compile_definitions(
  php_ext_iconv
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<PLATFORM_ID:Windows>:PHP_ICONV_EXPORTS>
)

find_package(Iconv)
set_package_properties(
  Iconv
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the iconv extension."
)

target_link_libraries(php_ext_iconv PRIVATE Iconv::Iconv)

if(TARGET Iconv::Iconv)
  # Sanity and library type checks.
  if(Iconv_IS_BUILT_IN)
    # When iconv is built into C library, first check if iconv function exists.
    check_symbol_exists(iconv iconv.h _PHP_HAVE_ICONV)

    # And if not, then check for libiconv function.
    if(NOT _PHP_HAVE_ICONV)
      check_symbol_exists(libiconv iconv.h HAVE_LIBICONV)
    endif()
  else()
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)

      check_symbol_exists(libiconv iconv.h HAVE_LIBICONV)

      if(HAVE_LIBICONV)
        set(ICONV_ALIASED_LIBICONV TRUE)
      else()
        check_symbol_exists(iconv iconv.h _PHP_HAVE_ICONV)
      endif()
    cmake_pop_check_state()
  endif()

  if(NOT _PHP_HAVE_ICONV AND NOT HAVE_LIBICONV)
    message(
      FATAL_ERROR
      "ext/iconv sanity check failed: neither 'iconv()' nor 'libiconv()' "
      "function could be found."
    )
  endif()

  message(CHECK_START "Checking the iconv implementation")

  # Check for GNU libiconv implementation.
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_symbol_exists(_libiconv_version iconv.h _PHP_HAVE_GNU_LIBICONV)
  cmake_pop_check_state()
  if(_PHP_HAVE_GNU_LIBICONV)
    message(CHECK_PASS "GNU libiconv")
    set(HAVE_LIBICONV TRUE)
    set(PHP_ICONV_IMPL "libiconv")
  endif()

  # Check for glibc implementation.
  if(NOT _PHP_HAVE_GNU_LIBICONV)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)
      set(CMAKE_REQUIRED_QUIET TRUE)
      check_symbol_exists(gnu_get_libc_version gnu/libc-version.h HAVE_GLIBC_ICONV)
    cmake_pop_check_state()
  endif()
  if(HAVE_GLIBC_ICONV)
    message(CHECK_PASS "GNU C library")
    set(PHP_ICONV_IMPL "glibc")
  endif()

  # Check for Konstantin Chuguev's iconv implementation.
  if(NOT _PHP_HAVE_GNU_LIBICONV AND NOT HAVE_GLIBC_ICONV)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)
      set(CMAKE_REQUIRED_QUIET TRUE)
      check_symbol_exists(iconv_ccs_init iconv.h _PHP_HAVE_BSD_ICONV)
    cmake_pop_check_state()
  endif()
  if(_PHP_HAVE_BSD_ICONV)
    message(CHECK_PASS "BSD iconv")
    set(PHP_ICONV_IMPL "BSD iconv")
  endif()

  # Check for IBM iconv implementation.
  if(NOT _PHP_HAVE_GNU_LIBICONV AND NOT HAVE_GLIBC_ICONV AND NOT _PHP_HAVE_BSD_ICONV)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)
      set(CMAKE_REQUIRED_QUIET TRUE)
      check_symbol_exists(cstoccsid iconv.h HAVE_IBM_ICONV)
    cmake_pop_check_state()
  endif()
  if(HAVE_IBM_ICONV)
    message(CHECK_PASS "IBM iconv")
    set(PHP_ICONV_IMPL "IBM iconv")
  endif()

  if(NOT PHP_ICONV_IMPL AND Iconv_IS_BUILT_IN)
    message(CHECK_PASS "built in C library ${PHP_C_STANDARD_LIBRARY}")
  elseif(NOT PHP_ICONV_IMPL)
    message(CHECK_FAIL "not found, unknown")
  endif()

  # Sanity check. Check if iconv supports errno.
  message(CHECK_START "Checking if iconv supports errno")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_runs(C [[
      #include <iconv.h>
      #include <errno.h>

      int main(void)
      {
        iconv_t cd;
        cd = iconv_open("*to*", "*from*");
        if (cd == (iconv_t)(-1)) {
          if (errno == EINVAL) {
            return 0;
          } else {
            return 1;
          }
        }
        iconv_close(cd);
        return 2;
      }
    ]] PHP_ICONV_ERRNO_WORKS)
  cmake_pop_check_state()
  if(PHP_ICONV_ERRNO_WORKS)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_PASS "no")
    message(FATAL_ERROR "The iconv 'errno' sanity check failed.")
  endif()

  message(CHECK_START "Checking if iconv supports //IGNORE")
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_runs(C [[
      #include <iconv.h>
      #include <stdlib.h>

      int main(void)
      {
        iconv_t cd = iconv_open("UTF-8//IGNORE", "UTF-8");
        if(cd == (iconv_t)-1) {
          return 0;
        }
        char *in_p = "\xC3\xC3\xC3\xB8";
        size_t in_left = 4, out_left = 4096;
        char *out = malloc(out_left);
        char *out_p = out;
        size_t result = iconv(
          cd,
          (char **) &in_p,
          &in_left,
          (char **) &out_p,
          &out_left
        );
        if(result == (size_t)-1) {
          return 0;
        }
        return 1;
      }
    ]] ICONV_BROKEN_IGNORE)
  cmake_pop_check_state()
  if(ICONV_BROKEN_IGNORE)
    message(CHECK_FAIL "no")
  else()
    message(CHECK_PASS "yes")
  endif()
endif()

set(HAVE_ICONV TRUE)

configure_file(cmake/config.h.in config.h)
