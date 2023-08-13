option(soap "Whether to enable the SOAP extension" OFF)

if(soap)
  if(NOT libxml)
    message(FATAL_ERROR "SOAP extension requires LIBXML extension, add -Dlibxml=ON")
  endif()

  string(TOLOWER ${soap} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME "soap" ${extension_library_type})

  add_library(ext_soap ${extension_library_type}
    soap.c
    php_encoding.c
    php_http.c
    php_packet_soap.c
    php_schema.c
    php_sdl.c
    php_xml.c
  )

  target_compile_definitions(ext_soap PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

  target_link_libraries(ext_soap ext_libxml)
endif()
