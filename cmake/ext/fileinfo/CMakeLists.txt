include(CheckCSourceRuns)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_FILEINFO "Enable the fileinfo extension" ON)

add_feature_info("ext/fileinfo" EXT_FILEINFO
  "Adds support for file content type and encoding."
)

cmake_dependent_option(
  EXT_FILEINFO_SHARED
  "Build the fileinfo extension as a shared library"
  OFF
  "EXT_FILEINFO;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_FILEINFO)
  return()
endif()

if(EXT_FILEINFO_SHARED)
  add_library(php_fileinfo SHARED)
else()
  add_library(php_fileinfo)
endif()

target_sources(php_fileinfo PRIVATE
  fileinfo.c
  php_libmagic.c
  libmagic/apprentice.c
  libmagic/apptype.c
  libmagic/ascmagic.c
  libmagic/buffer.c
  libmagic/cdf_time.c
  libmagic/cdf.c
  libmagic/compress.c
  libmagic/der.c
  libmagic/encoding.c
  libmagic/fsmagic.c
  libmagic/funcs.c
  libmagic/is_csv.c
  libmagic/is_json.c
  libmagic/is_tar.c
  libmagic/magic.c
  libmagic/print.c
  libmagic/readcdf.c
  libmagic/softmagic.c
)

check_symbol_exists(utimes "sys/time.h" HAVE_UTIMES)
check_symbol_exists(strndup "string.h" HAVE_STRNDUP)

message(CHECK_START "Checking for strcasestr")

if(NOT CMAKE_CROSSCOMPILING)
  check_c_source_runs("
    #include <string.h>
    #include <strings.h>
    #include <stdlib.h>

    int main(void) {
      char *s0, *s1, *ret;

      s0 = (char *) malloc(42);
      s1 = (char *) malloc(8);

      memset(s0, 'X', 42);
      s0[24] = 'Y';
      s0[26] = 'Z';
      s0[41] = '\\\\0';
      memset(s1, 'x', 8);
      s1[0] = 'y';
      s1[2] = 'Z';
      s1[7] = '\\\\0';

      ret = strcasestr(s0, s1);

      return !(NULL != ret);
    }
  " HAVE_PLATFORM_STRCASESTR)
endif()

if(HAVE_PLATFORM_STRCASESTR)
  message(CHECK_PASS "using platform strcasestr")
else()
  target_sources(php_fileinfo PRIVATE libmagic/strcasestr.c)
  message(CHECK_FAIL "using libmagic strcasestr")
  message(WARNING "Using libmagic strcasestr implementation instead of platform")
endif()

target_include_directories(
  php_fileinfo
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/libmagic
)
