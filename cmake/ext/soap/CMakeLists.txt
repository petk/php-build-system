include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SOAP "Enable the soap extension" OFF)

add_feature_info(
  "ext/soap"
  EXT_SOAP
  "Support for writing SOAP servers and clients."
)

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

target_sources(
  php_soap
  PRIVATE
    php_encoding.c
    php_http.c
    php_packet_soap.c
    php_schema.c
    php_sdl.c
    php_xml.c
    soap.c
)

target_compile_definitions(
  php_soap
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
)

set(HAVE_PHP_SOAP 1 CACHE INTERNAL "Whether the soap extension is enabled")

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})
set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the soap extension."
)

target_link_libraries(php_soap PRIVATE LibXml2::LibXml2)

add_dependencies(php_soap php_libxml)
