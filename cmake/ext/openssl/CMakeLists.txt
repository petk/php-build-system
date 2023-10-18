set_directory_properties(PROPERTIES PHP_PRIORITY 2)

include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(EXT_OPENSSL "Whether to enable the openssl extension" OFF)

cmake_dependent_option(
  EXT_OPENSSL_SHARED
  "Whether to build the openssl extension as shared object"
  OFF
  "EXT_OPENSSL;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_OPENSSL_KERBEROS
  "Whether to include Kerberos support for OpenSSL"
  OFF
  "EXT_OPENSSL"
  OFF
)

cmake_dependent_option(
  EXT_OPENSSL_SYSTEM_CIPHERS
  "Whether to use system default cipher list instead of hardcoded value for OpenSSL"
  OFF
  "EXT_OPENSSL"
  OFF
)

if(NOT EXT_OPENSSL)
  return()
endif()

if(EXT_OPENSSL_SHARED)
  set(_type "SHARED")
endif()

add_library(php_openssl ${_type}
  openssl.c
  xp_ssl.c
)

if(EXT_OPENSSL_KERBEROS)
  find_package(Kerberos REQUIRED)

  target_link_libraries(php_openssl PRIVATE Kerberos::Kerberos)
endif()

find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION} REQUIRED)

target_link_libraries(php_openssl PRIVATE OpenSSL::SSL)
target_link_libraries(php_openssl PRIVATE OpenSSL::Crypto)

set(HAVE_OPENSSL_EXT 1 CACHE INTERNAL "Whether the OpenSSL extension is available")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_LIBRARIES OpenSSL::SSL)
  check_symbol_exists(RAND_egd "openssl/rand.h" HAVE_RAND_EGD)
cmake_pop_check_state()

if(EXT_OPENSSL_SYSTEM_CIPHERS)
  set(USE_OPENSSL_SYSTEM_CIPHERS 1 CACHE INTERNAL "Use system default cipher list instead of hardcoded value")
endif()
