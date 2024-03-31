include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckSourceRuns)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_CURL "Enable the curl extension" OFF)

add_feature_info(
  "ext/curl"
  EXT_CURL
  "Support for using CURL - Client URL Library."
)

cmake_dependent_option(
  EXT_CURL_SHARED
  "Build the curl extension as a shared library"
  OFF
  "EXT_CURL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_CURL)
  return()
endif()

if(EXT_CURL_SHARED)
  add_library(php_curl SHARED)
else()
  add_library(php_curl)
endif()

target_sources(
  php_curl
  PRIVATE
    curl_file.c
    interface.c
    multi.c
    share.c
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

target_link_libraries(php_curl PRIVATE CURL::libcurl)

# Check whether to link against OpenSSL to have crypto locking callbacks when
# thread safety is enabled. If libcurl is linked against OpenSSL 1.1 or newer,
# linking isn't needed anymore.
if(PHP_THREAD_SAFETY AND CURL_SSL_FOUND)
  message(CHECK_START "Checking if libcurl is linked against old OpenSSL < 1.1")

  if(NOT CMAKE_CROSSCOMPILING)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES CURL::libcurl)
      set(CMAKE_REQUIRED_QUIET TRUE)

      check_source_runs(C [[
        #include <stdio.h>
        #include <strings.h>
        #include <curl/curl.h>

        int main(int argc, char *argv[]) {
          curl_version_info_data *data = curl_version_info(CURLVERSION_NOW);

          if (data && data->ssl_version && *data->ssl_version) {
            const char *ptr = data->ssl_version;

            while(*ptr == ' ') ++ptr;
            int major, minor;
            if (sscanf(ptr, "OpenSSL/%d", &major) == 1) {
              if (major >= 3) {
                /* OpenSSL version 3 or later */
                return 4;
              }
            }
            if (sscanf(ptr, "OpenSSL/%d.%d", &major, &minor) == 2) {
              if (major > 1 || (major == 1 && minor >= 1)) {
                /* OpenSSL version 1.1 or later */
                return 3;
              }
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
      ]] HAVE_CURL_OLD_OPENSSL)
    cmake_pop_check_state()
  endif()

  if(NOT HAVE_CURL_OLD_OPENSSL)
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

    target_link_libraries(php_curl PRIVATE OpenSSL::Crypto)

    check_include_file(openssl/crypto.h HAVE_OPENSSL_CRYPTO_H)
  endif()
endif()

# Sanity check.
if(TARGET CURL::libcurl)
  check_library_exists(CURL::libcurl curl_easy_perform "" HAVE_CURL_EASY_PERFORM)

  if(NOT HAVE_CURL_EASY_PERFORM)
    message(
      FATAL_ERROR
      "The curl_easy_perform() couldn't be found. Please check logs for more "
      "information."
    )
  endif()
endif()

install(
  TARGETS php_curl
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/ext/curl
)
