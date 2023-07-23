option(fileinfo "Whether to enable the fileinfo extension" ON)

if(fileinfo)
  php_extension(NAME fileinfo)

  check_symbol_exists(utimes "sys/time.h" HAVE_UTIMES)
  check_symbol_exists(strndup "string.h" HAVE_STRNDUP)

  message(STATUS "Checking for strcasestr")

  add_library(ext_fileinfo
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

  try_run(
    RUN_RESULT_VAR
    COMPILE_RESULT_VAR
    ${CMAKE_BINARY_DIR}
    "${CMAKE_SOURCE_DIR}/cmake/fileinfo_test.c"
  )

  if(RUN_RESULT_VAR EQUAL 0 AND COMPILE_RESULT_VAR)
    message("using the platform implementation of strcasestr")
  else()
    target_sources(ext_fileinfo PRIVATE libmagic/strcasestr.c)
    message(STATUS "using libmagic strcasestr implementation")
  endif()

  target_include_directories(
    ext_fileinfo
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}"
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/libmagic"
  )

  target_compile_definitions(ext_fileinfo PUBLIC HAVE_CONFIG_H)
endif()
