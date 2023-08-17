include(CheckSymbolExists)
include(CMakeDependentOption)

option(openssl "Whether to enable the openssl extension" OFF)

cmake_dependent_option(openssl_kerberos "Whether to include Kerberos support for OpenSSL" OFF "openssl" OFF)

cmake_dependent_option(openssl_system_ciphers "Whether to use system default cipher list instead of hardcoded value for OpenSSL" OFF "openssl" OFF)

if(NOT openssl)
  return()
endif()

string(TOLOWER ${openssl} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "openssl" ${extension_library_type} PRIORITY 2)

add_library(ext_openssl ${extension_library_type}
  openssl.c
  xp_ssl.c
)

check_symbol_exists(RAND_egd "openssl/rand.h" HAVE_RAND_EGD)

if(openssl_kerberos)
  find_package(KERBEROS)

  if(KERBEROS_FOUND)
    target_link_libraries(ext_openssl PRIVATE ${KERBEROS_LIBRARIES})
    target_include_directories(ext_openssl PRIVATE ${KERBEROS_INCLUDE_DIRS})
  endif()
endif()

find_package(OpenSSL 1.0.2 REQUIRED)

if(OPENSSL_FOUND)
  set(HAVE_OPENSSL_EXT 1 CACHE INTERNAL "Whether the OpenSSL extension is available")

  target_link_libraries(ext_openssl PRIVATE ${OPENSSL_LIBRARIES})
  target_include_directories(ext_openssl PRIVATE ${OPENSSL_INCLUDE_DIRS})
endif()

if(openssl_system_ciphers)
  set(USE_OPENSSL_SYSTEM_CIPHERS 1 CACHE INTERNAL "Use system default cipher list instead of hardcoded value")
endif()
