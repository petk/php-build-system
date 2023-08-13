option(xmlreader "Whether to enable the xmlreader extension" ON)

if(xmlreader)
  if(NOT libxml)
    message(FATAL_ERROR "XMLReader extension requires LIBXML extension, add -Dlibxml=ON")
  endif()

  string(TOLOWER ${xmlreader} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME "xmlreader" ${extension_library_type})

  add_library(ext_xmlreader ${extension_library_type}
    php_xmlreader.c
  )

  target_link_libraries(ext_xmlreader ext_libxml)
endif()
