option(EXT_LIBXML "Whether to enable the libxml extension" ON)

if(NOT EXT_LIBXML)
  return()
endif()

# This extension can be build only as STATIC.
php_extension(NAME "libxml" STATIC PRIORITY 1)

add_library(libxml STATIC
  libxml.c
)

target_compile_definitions(libxml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(LibXml2 2.9.0 REQUIRED)

if(TARGET LibXml2::LibXml2)
  target_link_libraries(libxml PUBLIC LibXml2::LibXml2)
endif()

target_sources(
  libxml
  PUBLIC FILE_SET libxml_headers
  TYPE HEADERS
  FILES php_libxml.h
)

install(
  TARGETS libxml
  FILE_SET libxml_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/libxml
)
