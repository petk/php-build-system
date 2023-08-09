include(CheckCSourceRuns)

option(fileinfo "Whether to enable the fileinfo extension" ON)

if(fileinfo)
  check_symbol_exists(utimes "sys/time.h" HAVE_UTIMES)
  check_symbol_exists(strndup "string.h" HAVE_STRNDUP)

  string(TOLOWER ${fileinfo} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME fileinfo ${extension_library_type})

  add_library(ext_fileinfo ${extension_library_type}
    fileinfo.c
    php_libmagic.c
    libmagic/apprentice.c
    libmagic/apptype.c
    libmagic/ascmagic.c
    libmagic/cdf.c
    libmagic/cdf_time.c
    libmagic/compress.c
    libmagic/encoding.c
    libmagic/fsmagic.c
    libmagic/funcs.c
    libmagic/is_json.c
    libmagic/is_tar.c
    libmagic/magic.c
    libmagic/print.c
    libmagic/readcdf.c
    libmagic/softmagic.c
    libmagic/der.c
    libmagic/buffer.c
    libmagic/is_csv.c
  )

  message(STATUS "Checking for strcasestr")

  if(NOT CMAKE_CROSSCOMPILING)
    check_c_source_runs("
      #include <string.h>
      #include <strings.h>
      #include <stdlib.h>

      int main(void)
      {
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
    " successful)
  endif()

  if(successful)
    message(STATUS "using the platform implementation of strcasestr")
  else()
    target_sources(ext_fileinfo PRIVATE libmagic/strcasestr.c)
    message(STATUS "using libmagic strcasestr implementation")
  endif()

  unset(successful)

  target_include_directories(
    ext_fileinfo
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}"
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/libmagic"
  )

  target_compile_definitions(ext_fileinfo PRIVATE HAVE_CONFIG_H)
endif()
