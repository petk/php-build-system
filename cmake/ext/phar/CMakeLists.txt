include(CMakeDependentOption)

option(EXT_PHAR "Whether to enable the phar extension" ON)

cmake_dependent_option(
  EXT_PHAR_SHARED
  "Whether to build the phar extension as shared object"
  OFF
  "EXT_PHAR;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PHAR)
  return()
endif()

if(EXT_PHAR_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "phar" ${_library_type})

add_library(php_phar ${_library_type}
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

if(RE2C_FOUND)
  re2c_target(
    NAME php_phar_path_check
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c"
    OPTIONS "--no-generation-date -b"
  )
endif()

target_compile_definitions(php_phar PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

message(STATUS "Checking for phar openssl support")

if(EXT_OPENSSL)
  message(STATUS "Openssl support enabled")
  set(PHAR_HAVE_OPENSSL 1 CACHE INTERNAL "Define to 1 if PHP extension openssl is enabled")
else()
  message(STATUS "PHP extension openssl is shared or disabled, skipping")
endif()

# Man documentation.
configure_file(phar.1.in phar.1 @ONLY)
configure_file(phar.1.in phar.phar.1 @ONLY)

target_sources(
  php_phar
  PUBLIC FILE_SET phar_headers
  TYPE HEADERS
  FILES
    php_phar.h
)

install(
  TARGETS php_phar
  FILE_SET phar_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/phar
)

install(
  FILES
    phar.1
    phar.phar.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)
