include(CheckSymbolExists)
include(CMakeDependentOption)

option(EXT_OPENSSL "Whether to enable the openssl extension" OFF)

cmake_dependent_option(EXT_OPENSSL_SHARED "Whether to build the openssl extension as shared object" OFF "EXT_OPENSSL;NOT BUILD_SHARED_LIBS" OFF)

cmake_dependent_option(EXT_OPENSSL_KERBEROS "Whether to include Kerberos support for OpenSSL" OFF "EXT_OPENSSL" OFF)

cmake_dependent_option(EXT_OPENSSL_SYSTEM_CIPHERS "Whether to use system default cipher list instead of hardcoded value for OpenSSL" OFF "EXT_OPENSSL" OFF)

if(NOT EXT_OPENSSL)
  return()
endif()

if(EXT_OPENSSL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "openssl" ${_library_type} PRIORITY 2)

add_library(ext_openssl ${_library_type}
  openssl.c
  xp_ssl.c
)

check_symbol_exists(RAND_egd "openssl/rand.h" HAVE_RAND_EGD)

if(EXT_OPENSSL_KERBEROS)
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

if(EXT_OPENSSL_SYSTEM_CIPHERS)
  set(USE_OPENSSL_SYSTEM_CIPHERS 1 CACHE INTERNAL "Use system default cipher list instead of hardcoded value")
endif()
