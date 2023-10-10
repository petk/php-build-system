include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

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

add_library(php_openssl ${_library_type}
  openssl.c
  xp_ssl.c
)

if(EXT_OPENSSL_KERBEROS)
  find_package(Kerberos REQUIRED)

  if(TARGET Kerberos::Kerberos)
    target_link_libraries(php_openssl PRIVATE Kerberos::Kerberos)
  endif()
endif()

find_package(OpenSSL 1.0.2 REQUIRED)

set(HAVE_OPENSSL_EXT 1 CACHE INTERNAL "Whether the OpenSSL extension is available")

if(TARGET OpenSSL::SSL)
  target_link_libraries(php_openssl PRIVATE OpenSSL::SSL)
endif()

if(TARGET OpenSSL::Crypto)
  target_link_libraries(php_openssl PRIVATE OpenSSL::Crypto)
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES OpenSSL::SSL)
  check_symbol_exists(RAND_egd "openssl/rand.h" HAVE_RAND_EGD)
cmake_pop_check_state()

if(EXT_OPENSSL_SYSTEM_CIPHERS)
  set(USE_OPENSSL_SYSTEM_CIPHERS 1 CACHE INTERNAL "Use system default cipher list instead of hardcoded value")
endif()
