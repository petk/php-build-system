option(EXT_GMP "Whether to enable the GMP extension" OFF)

cmake_dependent_option(
  EXT_GMP_SHARED
  "Whether to build the GMP extension as shared object"
  OFF
  "EXT_GMP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_GMP)
  return()
endif()

if(EXT_GMP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_gmp ${_library_type}
  gmp.c
)

add_library(PHP::gmp ALIAS php_gmp)

set_target_properties(php_gmp PROPERTIES OUTPUT_NAME gmp)

target_compile_definitions(php_gmp PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(GMP 4.2 REQUIRED)

target_link_libraries(php_gmp PRIVATE GMP::GMP)

target_sources(
  php_gmp
  PUBLIC FILE_SET gmp_headers
  TYPE HEADERS
  FILES php_gmp_int.h
)

install(
  TARGETS php_gmp
  FILE_SET gmp_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/gmp
)
