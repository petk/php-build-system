#[=============================================================================[
# The curl extension

This extension provides support for using CURL - Client URL Library.

## Configuration options

### PHP_EXT_CURL

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_CURL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_CURL
  LANGUAGES C
)

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

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(curl)

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

find_package(CURL 7.61.0 OPTIONAL_COMPONENTS SSL)
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
)

target_link_libraries(php_ext_curl PRIVATE CURL::CURL)

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
  message(
    CHECK_START
    "Checking whether libcurl is linked against a supported OpenSSL version"
  )

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES CURL::CURL)
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

          if (sscanf(ptr, "OpenSSL/%d.%d", &major, &minor) == 2) {
            /* Check for 1.1.1+ (including 1.1.1a, 1.1.1b, etc.) */
            if (
              (major > 1)
              || (major == 1 && minor == 1 && strncmp(ptr + 12, "1", 1) == 0)) {
              /* OpenSSL 1.1.1+ - supported */
              return 3;
            }

            /* OpenSSL 1.1.0 and earlier - unsupported */
            return 0;
          }

          if (strncasecmp(ptr, "OpenSSL", sizeof("OpenSSL")-1) == 0) {
            /* Old OpenSSL version */
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

  if(PHP_EXT_CURL_HAVE_CURL_OLD_OPENSSL)
    message(CHECK_FAIL "no")
    message(
      FATAL_ERROR
      "libcurl is linked against an unsupported OpenSSL version. OpenSSL "
      "${PHP_OPENSSL_MIN_VERSION} or later is required."
    )
  else()
    message(CHECK_PASS "yes")
  endif()
endif()

set(HAVE_CURL TRUE)

configure_file(cmake/config.h.in config.h)
