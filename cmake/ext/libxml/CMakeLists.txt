include(FeatureSummary)

option(EXT_LIBXML "Enable the libxml extension" ON)

add_feature_info("ext/libxml" EXT_LIBXML
  "Adds support for XML parser and toolkit libxml. Can be built only as static."
)

if(NOT EXT_LIBXML)
  return()
endif()

# This extension can be built only as a STATIC library.
add_library(php_libxml STATIC
  libxml.c
)

target_compile_definitions(php_libxml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})
set_package_properties(LibXml2 PROPERTIES
  TYPE REQUIRED
  PURPOSE "Necessary to enable the libxml extension."
)

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
