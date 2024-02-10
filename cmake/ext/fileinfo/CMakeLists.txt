include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_FILEINFO "Enable the fileinfo extension" ON)

add_feature_info(
  "ext/fileinfo"
  EXT_FILEINFO
  "Support for file content type and encoding."
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

target_sources(
  php_fileinfo
  PRIVATE
    fileinfo.c
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
    php_libmagic.c
)

check_symbol_exists(utimes "sys/time.h" HAVE_UTIMES)
check_symbol_exists(strndup "string.h" HAVE_STRNDUP)

# The strcasestr is missing on Windows and Solaris 10 (Solaris 11 has it).
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(strcasestr "string.h" HAVE_STRCASESTR)
cmake_pop_check_state()

if(NOT HAVE_STRCASESTR)
  message(STATUS "Using libmagic strcasestr implementation")
  target_sources(php_fileinfo PRIVATE libmagic/strcasestr.c)
endif()
