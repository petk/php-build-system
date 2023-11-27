include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_ICONV "Enable the iconv extension" ON)

add_feature_info("ext/iconv" EXT_ICONV
  "Support for interface to iconv character set conversion facility."
)

cmake_dependent_option(
  EXT_ICONV_SHARED
  "Build the iconv extension as a shared library"
  OFF
  "EXT_ICONV;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ICONV)
  return()
endif()

if(EXT_ICONV_SHARED)
  add_library(php_iconv SHARED)
else()
  add_library(php_iconv)
endif()

target_sources(php_iconv PRIVATE
  iconv.c
)

target_compile_definitions(php_iconv PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(Iconv_ROOT)
  # Disable built-in iconv when overridding search paths in CMake's FindIconv.
  set(Iconv_IS_BUILT_IN FALSE)

  # GNU libiconv on Alpine Linux has header located on a special location.
  find_path(_php_iconv_include_dir NAMES "gnu-libiconv/iconv.h")
  if(_php_iconv_include_dir)
    set(Iconv_INCLUDE_DIR "${_php_iconv_include_dir}/gnu-libiconv")
  endif()
endif()

find_package(Iconv)
set_package_properties(Iconv PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the iconv extension."
)

target_link_libraries(php_iconv PRIVATE Iconv::Iconv)

if(TARGET Iconv::Iconv)
  # Sanity and library type checks.
  if(Iconv_IS_BUILT_IN)
    # When iconv is built into C library, first check if iconv function exists.
    check_symbol_exists(iconv "iconv.h" HAVE_ICONV)

    # And if not, then check for libiconv function.
    if(NOT HAVE_ICONV)
      check_symbol_exists(libiconv "iconv.h" HAVE_LIBICONV)
    endif()
  elseif(Iconv_LIBRARIES)
    check_library_exists("${Iconv_LIBRARIES}" libiconv "" HAVE_LIBICONV)

    if(HAVE_LIBICONV)
      set(
        ICONV_ALIASED_LIBICONV 1
        CACHE INTERNAL "iconv() is aliased to libiconv() in -liconv"
      )
    else()
      check_library_exists("${Iconv_LIBRARIES}" iconv "" HAVE_ICONV)
    endif()
  endif()

  if(NOT HAVE_ICONV AND NOT HAVE_LIBICONV)
    message(
      FATAL_ERROR
      "The iconv sanity check failed. Neither iconv or libiconv could be found."
    )
  endif()

  message(CHECK_START "Checking the iconv implementation")

  # Check for GNU libiconv implementation.
  if(NOT CMAKE_CROSSCOMPILING)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)

      check_c_source_runs("
        #include <iconv.h>
        #include <stdio.h>
        int main(void) {
          printf(\"%d\", _libiconv_version);
          return 0;
        }
      " _have_gnu_libiconv)
    cmake_pop_check_state()
  endif()

  if(_have_gnu_libiconv)
    message(CHECK_PASS "GNU libiconv")
    set(HAVE_LIBICONV 1 CACHE INTERNAL "")
    set(PHP_ICONV_IMPL "libiconv" CACHE INTERNAL "The iconv library implementation")
  endif()

  # Check for glibc implementation.
  if(NOT _have_gnu_libiconv)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)

      check_c_source_compiles("
        #include <gnu/libc-version.h>
        int main(void) {
          gnu_get_libc_version();
          return 0;
        }
      " HAVE_GLIBC_ICONV)
    cmake_pop_check_state()
  endif()

  if(HAVE_GLIBC_ICONV)
    message(CHECK_PASS "GNU C library")
    set(PHP_ICONV_IMPL "glibc" CACHE INTERNAL "The iconv library implementation")
  endif()

  # Check for Konstantin Chuguev's iconv implementation.
  if(NOT _have_gnu_libiconv AND NOT HAVE_GLIBC_ICONV)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)

      check_c_source_compiles("
        #include <iconv.h>
        int main(void) {
          iconv_ccs_init(NULL, NULL);
          return 0;
        }
      " HAVE_BSD_ICONV)
    cmake_pop_check_state()
  endif()

  if(HAVE_BSD_ICONV)
    message(CHECK_PASS "BSD iconv")
    set(PHP_ICONV_IMPL "BSD iconv" CACHE INTERNAL "The iconv library implementation")
  endif()

  # Check for IBM iconv implementation.
  if(NOT _have_gnu_libiconv AND NOT HAVE_GLIBC_ICONV AND NOT HAVE_BSD_ICONV)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)

      check_c_source_compiles("
        #include <iconv.h>
        int main(void) {
          cstoccsid(\"\");
          return 0;
        }
      " HAVE_IBM_ICONV)
    cmake_pop_check_state()
  endif()

  if(HAVE_IBM_ICONV)
    message(CHECK_PASS "IBM iconv")
    set(PHP_ICONV_IMPL "IBM iconv" CACHE INTERNAL "The iconv library implementation")
  endif()

  if(NOT PHP_ICONV_IMPL)
    message(CHECK_FAIL "not found, unknown")
  endif()

  # Sanity check. Check if iconv supports errno.
  message(CHECK_START "Checking if iconv supports errno")
  if(CMAKE_CROSSCOMPILING)
    set(_php_iconv_errno_works 1)
  else()
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)

      check_c_source_runs("
        #include <iconv.h>
        #include <errno.h>

        int main(void) {
          iconv_t cd;
          cd = iconv_open(\"*blahblah*\", \"*blahblahblah*\");
          if (cd == (iconv_t)(-1)) {
            if (errno == EINVAL) {
              return 0;
            } else {
              return 1;
            }
          }
          iconv_close( cd );
          return 2;
        }
      " _php_iconv_errno_works)
    cmake_pop_check_state()
  endif()

  if(_php_iconv_errno_works)
    message(CHECK_PASS "yes")
  else()
    message(
      FATAL_ERROR
      "The iconv errno sanity check failed. Please check logs for details."
    )
  endif()

  message(CHECK_START "Checking if iconv supports //IGNORE")
  if(CMAKE_CROSSCOMPILING)
    set(_php_iconv_ignore_works 1)
  else()
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)

      check_c_source_runs("
        #include <iconv.h>
        #include <stdlib.h>

        int main(void) {
          iconv_t cd = iconv_open(\"UTF-8//IGNORE\", \"UTF-8\");
          if(cd == (iconv_t)-1) {
            return 1;
          }
          char *in_p = \"\\\\xC3\\\\xC3\\\\xC3\\\\xB8\";
          size_t in_left = 4, out_left = 4096;
          char *out = malloc(out_left);
          char *out_p = out;
          size_t result = iconv(cd, (char **) &in_p, &in_left, (char **) &out_p, &out_left);
          if(result == (size_t)-1) {
            return 1;
          }
          return 0;
        }
      " _php_iconv_ignore_works)
    cmake_pop_check_state()
  endif()
  if(_php_iconv_ignore_works)
    message(CHECK_PASS "yes")
    set(ICONV_BROKEN_IGNORE 0 CACHE INTERNAL "Whether iconv supports IGNORE")
  else()
    message(CHECK_FAIL "no")
    set(ICONV_BROKEN_IGNORE 1 CACHE INTERNAL "Whether iconv supports IGNORE")
  endif()
endif()

target_sources(
  php_iconv
  PUBLIC FILE_SET iconv_headers
  TYPE HEADERS
  FILES
    iconv_arginfo.h
    php_iconv.h
)

install(
  TARGETS php_iconv
  FILE_SET iconv_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/iconv
)
