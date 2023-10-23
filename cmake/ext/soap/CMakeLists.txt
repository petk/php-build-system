include(CMakeDependentOption)

option(EXT_SOAP "Enable the soap extension" OFF)

cmake_dependent_option(
  EXT_SOAP_SHARED
  "Build the soap extension as a shared library"
  OFF
  "EXT_SOAP;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SOAP)
  return()
endif()

if(EXT_SOAP_SHARED)
  add_library(php_soap SHARED)
else()
  add_library(php_soap)
endif()

target_sources(php_soap PRIVATE
  soap.c
  php_encoding.c
  php_http.c
  php_packet_soap.c
  php_schema.c
  php_sdl.c
  php_xml.c
)

target_compile_definitions(php_soap PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION} REQUIRED)

target_link_libraries(php_soap PRIVATE LibXml2::LibXml2)

set_target_properties(php_soap PROPERTIES PHP_EXTENSION_DEPENDENCIES php_libxml)
