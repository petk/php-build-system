option(openssl "Whether to enable the openssl extension" OFF)

if(NOT openssl)
  return()
endif()

string(TOLOWER ${openssl} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "openssl" PRIORITY 2)
