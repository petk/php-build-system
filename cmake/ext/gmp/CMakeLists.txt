option(EXT_GMP "Whether to enable the GMP extension" OFF)

cmake_dependent_option(EXT_GMP_SHARED "Whether to build the GMP extension as shared object" OFF "EXT_GMP;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_GMP)
  return()
endif()

if(EXT_GMP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "gmp" ${_library_type})

add_library(ext_gmp ${_library_type}
  gmp.c
)

target_compile_definitions(ext_gmp PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(GMP 4.2 REQUIRED)

if(GMP_LIBRARIES)
  target_link_libraries(ext_gmp PRIVATE ${GMP_LIBRARIES})
endif()

if(GMP_INCLUDE_DIRS)
  target_include_directories(ext_gmp PRIVATE ${GMP_INCLUDE_DIRS})
endif()

target_sources(
  ext_gmp
  PUBLIC FILE_SET ext_gmp_headers
  TYPE HEADERS
  FILES php_gmp_int.h
)

install(
  TARGETS ext_gmp
  FILE_SET ext_gmp_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/gmp
)
