include(CheckCSourceRuns)
include(CheckIncludeFile)
include(CMakePushCheckState)

option(curl "Whether to enable the curl extension" OFF)

if(NOT curl)
  return()
endif()

find_package(CURL 7.29.0 OPTIONAL_COMPONENTS SSL)

string(TOLOWER ${curl} ctype_lower)
set(ctype_library_type "STATIC")
if(ctype_lower STREQUAL "shared")
  set(ctype_library_type "SHARED")
endif()

php_extension(NAME "curl" ${extension_library_type})

add_library(ext_curl ${extension_library_type}
  interface.c
  multi.c
  share.c
  curl_file.c
)

set_target_properties(ext_curl PROPERTIES PUBLIC_HEADER "php_curl.h")

# Checking if libcurl is linked against old openssl.
if(CURL_SSL_FOUND)
  if(NOT CMAKE_CROSSCOMPILING)
    cmake_push_check_state()
      set(CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES} ${CURL_LIBRARIES}")
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

check_library_exists(curl curl_easy_perform "" HAVE_CURL_LIB)

if(NOT HAVE_CURL_LIB)
  message(FATAL_ERROR "The curl_easy_perform() couldn't be found. Please check logs for more information.")
endif()

unset(HAVE_CURL_LIB)

target_include_directories(ext_curl PRIVATE ${CURL_INCLUDE_DIRS})

target_link_libraries(ext_curl PRIVATE ${CURL_LIBRARIES})
