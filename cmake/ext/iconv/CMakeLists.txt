include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(EXT_ICONV "Enable the iconv extension" ON)

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

find_package(Iconv REQUIRED)

target_link_libraries(php_iconv PRIVATE Iconv::Iconv)

if(${Iconv_LIBRARIES})
  check_library_exists(${Iconv_LIBRARIES} libiconv "" HAVE_LIBICONV)
else()
  check_symbol_exists(libiconv "iconv.h" HAVE_LIBICONV)
endif()

if(HAVE_LIBICONV)
  set(ICONV_ALIASED_LIBICONV 1 CACHE INTERNAL "iconv() is aliased to libiconv() in -liconv")
else()
  if(${Iconv_LIBRARIES})
    check_library_exists(${Iconv_LIBRARIES} iconv "" _have_iconv)
  else()
    check_symbol_exists(iconv "iconv.h" _have_iconv)
  endif()

  if(NOT _have_iconv)
    message(FATAL_ERROR "There is something wrong with the iconv library. See the logs")
  endif()
endif()

# Check for glibc implementation.
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

if(HAVE_GLIBC_ICONV)
  set(PHP_ICONV_IMPL "glibc" CACHE INTERNAL "Which iconv implementation to use")
endif()

# Check iconv library is GNU libiconv.
if(NOT HAVE_GLIBC_ICONV AND NOT CMAKE_CROSSCOMPILING)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Iconv::Iconv)

    check_c_source_compiles("
      #include <iconv.h>
      #include <stdio.h>
      int main(void) {
        printf(\"%d\", _libiconv_version);
        return 0;
      }
    " _have_gnu_libiconf)
  cmake_pop_check_state()

  if(_have_gnu_libiconv)
    set(HAVE_LIBICONV 1 CACHE INTERNAL "")
    set(PHP_ICONV_IMPL "libiconv" CACHE INTERNAL "Which iconv implementation to use")
  endif()
endif()

if(NOT HAVE_GLIBC_ICONV AND NOT _have_gnu_libiconv)
  # Check for Konstantin Chuguev's iconv implementation.
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
  set(PHP_ICONV_IMPL "BSD iconv" CACHE INTERNAL "Which iconv implementation to use")
endif()

if(NOT HAVE_GLIBC_ICONV AND NOT _have_gnu_libiconv AND NOT HAVE_BSD_ICONV)
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
  set(PHP_ICONV_IMPL "IBM iconv" CACHE INTERNAL "Which iconv implementation to use")
endif()

if(NOT CMAKE_CROSSCOMPILING)
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
    " _ignore_works)
  cmake_pop_check_state()
endif()

if(_ignore_works)
  set(ICONV_BROKEN_IGNORE 0 CACHE INTERNAL "Whether iconv supports IGNORE")
else()
  set(ICONV_BROKEN_IGNORE 1 CACHE INTERNAL "Whether iconv supports IGNORE")
endif()

unset(_ignore_works CACHE)

# Check if iconv supports errno.
if(CMAKE_CROSSCOMPILING)
  set(_errno_works 1)
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
    " _errno_works)
  cmake_pop_check_state()
endif()

# Sanity check.
if(NOT _errno_works)
  message(FATAL_ERROR "Something is wrong with libiconv. See logs for details.")
endif()

file(GLOB _iconv_headers_files "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

target_sources(
  php_iconv
  PUBLIC FILE_SET iconv_headers
  TYPE HEADERS
  FILES ${_iconv_headers_files}
)

install(
  TARGETS php_iconv
  FILE_SET iconv_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/iconv
)
