option(phar "Whether to enable the phar extension" ON)

if(phar)
  php_extension(NAME "phar")

  message(STATUS "Checking for phar openssl support")
  if(openssl)
    message(STATUS "Openssl support enabled")
    set(PHAR_HAVE_OPENSSL 1 CACHE STRING "Define to 1 if PHP extension openssl is enabled")
  else()
    message(STATUS "PHP extension openssl is shared or disabled, skipping")
  endif()

  re2c_target(
    NAME PharLexer
    INPUT ${CMAKE_CURRENT_BINARY_DIR}/phar_path_check.re
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar_path_check.c
    OPTIONS "--no-generation-date -b"
  )

  add_library(ext_phar
    util.c
    tar.c
    zip.c
    stream.c
    func_interceptors.c
    dirstream.c
    phar.c
    phar_object.c
    phar_path_check.c
  )

  target_include_directories(
    ext_phar
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  )

  target_compile_definitions(ext_phar PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

  set_target_properties(ext_phar PROPERTIES PUBLIC_HEADER "php_phar.h")

  # Man pages.
  configure_file(phar.1.in phar.1 @ONLY)
  configure_file(phar.1.in phar.phar.1 @ONLY)
endif()
