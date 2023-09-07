include(CMakeDependentOption)

option(EXT_ICONV "Whether to enable the iconv extension" ON)

cmake_dependent_option(EXT_ICONV_SHARED "Whether to build the iconv extension as shared object" OFF "EXT_ICONV;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_ICONV)
  return()
endif()

if(EXT_ICONV_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "iconv" ${_library_type})

add_library(ext_iconv ${_library_type}
  iconv.c
)

target_compile_definitions(ext_iconv PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(ICONV REQUIRED)

if(${ICONV_LIBRARIES})
  target_link_libraries(ext_iconv PRIVATE ${ICONV_LIBRARIES})
endif()

if(${ICONV_INCLUDE_DIRS})
  target_include_directories(ext_iconv PRIVATE ${ICONV_INCLUDE_DIRS})
endif()

file(GLOB _ext_iconv_headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

target_sources(
  ext_iconv
  PUBLIC FILE_SET ext_iconv_headers
  TYPE HEADERS
  FILES ${_ext_iconv_headers}
)

install(
  TARGETS ext_iconv
  FILE_SET ext_iconv_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/iconv
)
