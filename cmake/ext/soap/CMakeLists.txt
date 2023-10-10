include(CMakeDependentOption)

option(EXT_SOAP "Whether to enable the SOAP extension" OFF)

cmake_dependent_option(EXT_SOAP_SHARED "Whether to build the SOAP extension as shared object" OFF "EXT_SOAP;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_SOAP)
  return()
endif()

if(NOT EXT_LIBXML)
  message(FATAL_ERROR "SOAP extension requires LIBXML extension, set EXT_LIBXML=ON")
endif()

if(EXT_SOAP_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "soap" ${_library_type})

add_library(php_soap ${_library_type}
  soap.c
  php_encoding.c
  php_http.c
  php_packet_soap.c
  php_schema.c
  php_sdl.c
  php_xml.c
)

target_compile_definitions(php_soap PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(php_soap PRIVATE php_libxml)
