add_library(main STATIC
  main.c
  snprintf.c
  spprintf.c
  fopen_wrappers.c
  php_scandir.c
  php_ini_builder.c
  php_ini.c
  SAPI.c
  rfc1867.c
  php_content_types.c
  strlcpy.c
  strlcat.c
  explicit_bzero.c
  reentrancy.c
  php_variables.c
  php_ticks.c
  network.c
  php_open_temporary_file.c
  php_odbc_utils.c
  safe_bcmp.c
  output.c getopt.c
  php_syslog.c
  fastcgi.c
  internal_functions.c
  internal_functions_cli.c
  streams/streams.c
  streams/cast.c
  streams/memory.c
  streams/filter.c
  streams/plain_wrapper.c
  streams/userspace.c
  streams/transports.c
  streams/xp_socket.c
  streams/mmap.c
  streams/glob_wrapper.c
)

target_include_directories(
  main
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
         "${CMAKE_CURRENT_SOURCE_DIR}/streams"
         "${CMAKE_SOURCE_DIR}/ext/date"
         "${CMAKE_SOURCE_DIR}/ext/hash"
         "${CMAKE_SOURCE_DIR}/ext/pcre"
         "${CMAKE_SOURCE_DIR}/ext/pcre/pcre2lib"
         "${CMAKE_SOURCE_DIR}/TSRM"
         "${CMAKE_SOURCE_DIR}/Zend"
)

target_compile_definitions(main PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(HAVE_DTRACE)
  add_dependencies(main zend_dtrace)
endif()

# Target main needs includes from the libxml library.
if(HAVE_LIBXML)
  target_link_libraries(main PRIVATE ext_libxml)
endif()

if(HAVE_LIBEXPAT)
  target_link_libraries(main PRIVATE ext_xml)
endif()
