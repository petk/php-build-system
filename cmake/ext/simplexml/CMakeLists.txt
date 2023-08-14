option(simplexml "Whether to enable the simplexml extension" ON)

if(NOT simplexml)
  return()
endif()

if(NOT libxml)
  message(FATAL_ERROR "SimpleXML extension requires LIBXML extension, add -Dlibxml=ON")
endif()

string(TOLOWER ${simplexml} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "simplexml" ${extension_library_type})

add_library(ext_simplexml ${extension_library_type}
  simplexml.c
)

set_target_properties(ext_simplexml PROPERTIES PUBLIC_HEADER "php_simplexml.h;php_simplexml_exports.h")

target_link_libraries(ext_simplexml ext_libxml)
