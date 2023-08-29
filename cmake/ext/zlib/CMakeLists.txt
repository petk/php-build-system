include(CMakeDependentOption)

option(EXT_ZLIB "Whether to enable the zlib extension (requires zlib >= 1.2.0.4)" OFF)

cmake_dependent_option(EXT_ZLIB_SHARED "Whether to build the zlib extension as shared object" OFF "EXT_ZLIB;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_ZLIB)
  return()
endif()

if(EXT_ZLIB_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME zlib ${_library_type})

add_library(ext_zlib ${_library_type}
  zlib.c
  zlib_fopen_wrapper.c
  zlib_filter.c
)

target_compile_definitions(ext_zlib PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(ZLIB 1.2.0.4 REQUIRED)

if(ZLIB_LIBRARIES)
  target_link_libraries(ext_zlib PRIVATE ${ZLIB_LIBRARIES})
endif()

if(ZLIB_INCLUDE_DIRS)
  target_include_directories(ext_zlib PRIVATE ${ZLIB_INCLUDE_DIRS})
endif()
