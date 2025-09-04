#[=============================================================================[
# The curl extension

Configure the `curl` extension.

This extension provides support for using CURL - Client URL Library.

## PHP_EXT_CURL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_CURL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.2)

project(
  PhpExtensionCurl
  LANGUAGES C
)

include(CheckIncludeFiles)
include(CheckSourceRuns)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_CURL "Enable the curl extension")

add_feature_info(
  "ext/curl"
  PHP_EXT_CURL
  "CURL (Client URL Library) support"
)

cmake_dependent_option(
  PHP_EXT_CURL_SHARED
  "Build the curl extension as a shared library"
  OFF
  PHP_EXT_CURL
  OFF
)

if(NOT PHP_EXT_CURL)
  return()
endif()

if(PHP_EXT_CURL_SHARED)
  add_library(php_ext_curl MODULE)
else()
  add_library(php_ext_curl OBJECT)
endif()

target_sources(
  php_ext_curl
  PRIVATE
    curl_file.c
    curl_file.stub.php
    interface.c
    multi.c
    share.c
    curl.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_curl.h
)

find_package(CURL 7.29.0 OPTIONAL_COMPONENTS SSL)
set_package_properties(
  CURL
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the curl extension."
)

target_compile_options(
  php_ext_curl
  PRIVATE
    $<$<PLATFORM_ID:Windows>:PHP_CURL_EXPORTS>
    # TODO: Add CURL_STATICLIB when curl is static library on Windows:
    $<$<AND:$<PLATFORM_ID:Windows>,$<BOOL:${TODO}>>:CURL_STATICLIB>
)

target_link_libraries(php_ext_curl PRIVATE CURL::libcurl)

# Check whether to link against OpenSSL to have crypto locking callbacks when
# thread safety is enabled. If libcurl is linked against OpenSSL 1.1 or newer,
# linking isn't needed anymore.
if(
  PHP_THREAD_SAFETY
  AND CURL_SSL_FOUND
  AND (
    NOT CMAKE_CROSSCOMPILING
    OR (CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
  )
)
  message(CHECK_START "Checking if libcurl is linked against old OpenSSL < 1.1")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES CURL::libcurl)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_runs(C [[
      #include <stdio.h>
      #include <strings.h>
      #include <curl/curl.h>

      int main(void)
      {
        curl_version_info_data *data = curl_version_info(CURLVERSION_NOW);

        if (data && data->ssl_version && *data->ssl_version) {
          const char *ptr = data->ssl_version;

          while (*ptr == ' ') {
            ++ptr;
          }

          int major, minor;

          /* OpenSSL >= 3 */
          if (sscanf(ptr, "OpenSSL/%d", &major) == 1 && major >= 3) {
            return 4;
          }

          /* OpenSSL >= 1.1 */
          if (
            sscanf(ptr, "OpenSSL/%d.%d", &major, &minor) == 2
            && (major > 1 || (major == 1 && minor >= 1))
          ) {
            return 3;
          }

          /* OpenSSL < 1.1 */
          if (strncasecmp(ptr, "OpenSSL", sizeof("OpenSSL")-1) == 0) {
            return 0;
          }

          /* Different SSL library */
          return 2;
        }

        /* No SSL support */
        return 1;
      }
    ]] PHP_EXT_CURL_HAVE_CURL_OLD_OPENSSL)
  cmake_pop_check_state()
  set(HAVE_CURL_OLD_OPENSSL ${PHP_EXT_CURL_HAVE_CURL_OLD_OPENSSL})

  if(NOT PHP_EXT_CURL_HAVE_CURL_OLD_OPENSSL)
    message(CHECK_FAIL "no")
  else()
    message(CHECK_PASS "yes")
    find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
    set_package_properties(
      OpenSSL
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary for crypto locking callbacks in the curl extension."
    )

    target_link_libraries(php_ext_curl PRIVATE OpenSSL::Crypto)

    if(TARGET OpenSSL::Crypto)
      cmake_push_check_state(RESET)
        set(CMAKE_REQUIRED_LIBRARIES OpenSSL::Crypto)
        check_include_files(openssl/crypto.h PHP_EXT_CURL_HAVE_OPENSSL_CRYPTO_H)
        set(HAVE_OPENSSL_CRYPTO_H ${PHP_EXT_CURL_HAVE_OPENSSL_CRYPTO_H})
      cmake_pop_check_state()
    endif()
  endif()
endif()

set(HAVE_CURL TRUE)

configure_file(cmake/config.h.in config.h)
