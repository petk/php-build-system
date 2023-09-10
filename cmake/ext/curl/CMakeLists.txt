include(CheckCSourceRuns)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(EXT_CURL "Whether to enable the curl extension" OFF)

cmake_dependent_option(EXT_CURL_SHARED "Whether to build the curl extension as shared object" OFF "EXT_CURL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_CURL)
  return()
endif()

if(EXT_CURL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "curl" ${_library_type})

add_library(ext_curl ${_library_type}
  interface.c
  multi.c
  share.c
  curl_file.c
)

find_package(CURL 7.29.0 REQUIRED OPTIONAL_COMPONENTS SSL)

if(CURL_LIBRARIES)
  target_link_libraries(ext_curl PRIVATE ${CURL_LIBRARIES})
endif()

if(CURL_INCLUDE_DIRS)
  target_include_directories(ext_curl PRIVATE ${CURL_INCLUDE_DIRS})
endif()

# Checking if libcurl is linked against old openssl.
if(CURL_SSL_FOUND)
  if(NOT CMAKE_CROSSCOMPILING)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES ${CURL_LIBRARIES})
      check_c_source_runs("
        #include <strings.h>
        #include <curl/curl.h>

        int main(int argc, char *argv[])
        {
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
endif()

if(HAVE_CURL_OLD_OPENSSL)
  find_package(OpenSSL)

  if(OPENSSL_FOUND)
    target_include_directories(ext_curl PRIVATE ${OPENSSL_INCLUDE_DIRS})
    target_link_libraries(ext_curl PRIVATE ${OPENSSL_LIBRARIES})

    check_include_file(openssl/crypto.h HAVE_OPENSSL_CRYPTO_H)
  endif()
endif()

check_library_exists(${CURL_LIBRARIES} curl_easy_perform "" _have_curl_lib)

if(NOT _have_curl_lib)
  message(FATAL_ERROR "The curl_easy_perform() couldn't be found. Please check logs for more information.")
endif()

unset(_have_curl_lib CACHE)

target_sources(
  ext_curl
  PUBLIC FILE_SET ext_curl_headers
  TYPE HEADERS
  FILES php_curl.h
)

install(
  TARGETS ext_curl
  FILE_SET ext_curl_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/curl
)
