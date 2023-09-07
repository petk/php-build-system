option(EXT_LIBXML "Whether to enable the libxml extension" ON)

if(NOT EXT_LIBXML)
  return()
endif()

# This extension can be build only as STATIC.
php_extension(NAME "libxml" STATIC PRIORITY 1)

add_library(ext_libxml STATIC
  libxml.c
)

target_compile_definitions(ext_libxml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(LibXml2 2.9.0 REQUIRED GLOBAL)

target_link_libraries(ext_libxml PUBLIC "${LIBXML2_LIBRARIES}")
target_include_directories(ext_libxml PUBLIC "${LIBXML2_INCLUDE_DIRS}")

target_sources(
  ext_libxml
  PUBLIC FILE_SET ext_libxml_headers
  TYPE HEADERS
  FILES php_libxml.h
)

install(
  TARGETS ext_libxml
  FILE_SET ext_libxml_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/libxml
)
