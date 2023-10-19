include(CheckCSourceRuns)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(EXT_CURL "Enable the curl extension" OFF)

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
  set(_type "SHARED")
endif()

add_library(php_curl ${_type}
  interface.c
  multi.c
  share.c
  curl_file.c
)

find_package(CURL 7.29.0 REQUIRED OPTIONAL_COMPONENTS SSL)

target_link_libraries(php_curl PRIVATE CURL::libcurl)

# Checking if libcurl is linked against old OpenSSL.
# TODO: OpenSSL 3.x is here detected as old OpenSSL. Is this ok?
if(PHP_ZTS AND CURL_SSL_FOUND)
  if(NOT CMAKE_CROSSCOMPILING)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES CURL::libcurl)

      check_c_source_runs("
        #include <strings.h>
        #include <curl/curl.h>

        int main(int argc, char *argv[]) {
          curl_version_info_data *data = curl_version_info(CURLVERSION_NOW);

          if (data && data->ssl_version && *data->ssl_version) {
            const char *ptr = data->ssl_version;

            while(*ptr == ' ') ++ptr;
            if (strncasecmp(ptr, \"OpenSSL/1.1\", sizeof(\"OpenSSL/1.1\")-1) == 0) {
              /* New OpenSSL version */
              return 3;
            }
            if (strncasecmp(ptr, \"OpenSSL\", sizeof(\"OpenSSL\")-1) == 0) {
              /* Old OpenSSL version */
              return 0;
            }
            /* Different SSL library */
            return 2;
          }
          /* No SSL support */
          return 1;
        }
      " HAVE_CURL_OLD_OPENSSL)
    cmake_pop_check_state()
  endif()

  if(HAVE_CURL_OLD_OPENSSL)
    # TODO: Should a minimum OpenSSL version be used here?
    find_package(OpenSSL REQUIRED)

    target_link_libraries(php_curl PRIVATE OpenSSL::Crypto)

    check_include_file(openssl/crypto.h HAVE_OPENSSL_CRYPTO_H)
  endif()
endif()

# Sanity check.
check_library_exists(CURL::libcurl curl_easy_perform "" _have_curl_lib)

if(NOT _have_curl_lib)
  message(FATAL_ERROR "The curl_easy_perform() couldn't be found. Please check logs for more information.")
endif()

target_sources(
  php_curl
  PUBLIC FILE_SET curl_headers
  TYPE HEADERS
  FILES php_curl.h
)

install(
  TARGETS php_curl
  FILE_SET curl_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/curl
)
