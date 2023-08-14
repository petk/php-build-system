option(xmlwriter "Whether to enable the xmlwriter extension" ON)

if(NOT xmlwriter)
  return()
endif()

if(NOT libxml)
  message(FATAL_ERROR "XMLWriter extension requires LIBXML extension, add -Dlibxml=ON")
endif()

string(TOLOWER ${xmlwriter} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "xmlwriter" ${extension_library_type})

add_library(ext_xmlwriter ${extension_library_type}
  php_xmlwriter.c
)

target_link_libraries(ext_xmlwriter ext_libxml)
