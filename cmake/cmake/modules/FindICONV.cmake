#[=============================================================================[
Find the Iconv library.

Module overrides the default CMake Iconv find module.

The following variables are set:

ICONV_INCLUDE_DIRS
  A list of include directories for Iconv library.
ICONV_LIBRARIES
  A list of Iconv libraries for linking to.

The following cache variables are set for using in PHP:

HAVE_GLIBC_ICONV
  Set to 1 if glibc implementation is used.
PHP_ICONV_IMPL
  String of the Iconv implementation.
HAVE_LIBICONV
  Set to 1 if GNU libiconv is used.
HAVE_BSD_ICONV
  Set to 1 if Konstantin Chuguev's iconv implementation is used.
HAVE_IBM_ICONV
  Set to 1 if IBM iconv implementation is used.
ICONV_ALIASED_LIBICONV
  Set to 1 if iconv() is aliased to libiconv() in -liconv.
ICONV_BROKEN_IGNORE
  Set to 1 if //IGNORE is not supported in found libiconv.
#]=============================================================================]

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CMakePushCheckState)
include(FindPackageHandleStandardArgs)

find_package(Iconv REQUIRED)

if(Iconv_LIBRARIES)
  set(ICONV_LIBRARIES "${Iconv_LIBRARIES}")
endif()

if(Iconv_INCLUDE_DIRS)
  set(ICONV_INCLUDE_DIRS "${Iconv_INCLUDE_DIRS}")
endif()

check_c_source_compiles("
  #include <gnu/libc-version.h>

  int main(void) {
    gnu_get_libc_version();
    return 0;
  }
" HAVE_GLIBC_ICONV)

if(HAVE_GLIBC_ICONV)
  set(PHP_ICONV_IMPL "glibc" CACHE INTERNAL "Which iconv implementation to use")
endif()

if(NOT HAVE_GLIBC_ICONV AND NOT CMAKE_CROSSCOMPILING)
  check_c_source_runs("
    #include <iconv.h>
    #include <stdio.h>
    int main(void) {
      printf(\"%d\", _libiconv_version);
      return 0;
    }
  " HAVE_LIBICONV)
endif()

if(HAVE_LIBICONV)
  set(PHP_ICONV_IMPL "libiconv" CACHE INTERNAL "Which iconv implementation to use")
endif()

if(NOT HAVE_LIBICONV)
  # Check for Konstantin Chuguev's iconv implementation.
  check_c_source_compiles("
    #include <iconv.h>

    int main(void) {
      iconv_ccs_init(NULL, NULL);

      return 0;
    }
  " HAVE_BSD_ICONV)
endif()

if(HAVE_BSD_ICONV)
  set(PHP_ICONV_IMPL "BSD iconv" CACHE INTERNAL "Which iconv implementation to use")
endif()

if(NOT HAVE_BSD_ICONV)
  check_c_source_compiles("
    #include <iconv.h>

    int main(void) {
      cstoccsid(\"\");

      return 0;
    }
  " HAVE_IBM_ICONV)
endif()

if(HAVE_IBM_ICONV)
  set(PHP_ICONV_IMPL "IBM iconv" CACHE INTERNAL "Which iconv implementation to use")
endif()

check_symbol_exists(iconv "iconv.h" HAVE_ICONV)

if(NOT HAVE_ICONV)
  check_symbol_exists(libiconv "iconv.h" HAVE_LIBICONV)
endif()

check_library_exists(iconv libiconv "" _have_iconv_library)

if(_have_iconv_library)
  set(HAVE_LIBICONV 1 CACHE INTERNAL "" FORCE)
  set(ICONV_ALIASED_LIBICONV 1 CACHE INTERNAL "iconv() is aliased to libiconv() in -liconv")
endif()

unset(_have_iconv_library)

if(NOT CMAKE_CROSSCOMPILING)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES ${ICONV_LIBRARIES})
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
    set(CMAKE_REQUIRED_LIBRARIES ${ICONV_LIBRARIES})
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

find_package_handle_standard_args(
  ICONV
  REQUIRED_VARS PHP_ICONV_IMPL _errno_works
)

unset(_errno_works)
unset(_errno_works CACHE)
