option(EXT_LIBXML "Enable the libxml extension" ON)

if(NOT EXT_LIBXML)
  return()
endif()

# This extension can be built only as a STATIC library.
add_library(php_libxml STATIC
  libxml.c
)

target_compile_definitions(php_libxml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION} REQUIRED)

target_link_libraries(php_libxml PUBLIC LibXml2::LibXml2)

target_sources(
  php_libxml
  PUBLIC FILE_SET libxml_headers
  TYPE HEADERS
  FILES php_libxml.h
)

install(
  TARGETS php_libxml
  FILE_SET libxml_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/libxml
)
