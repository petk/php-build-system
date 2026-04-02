#[=============================================================================[
# The sockets extension

This extension provides support for a low-level socket communication interface.

## Configuration options

### PHP_EXT_SOCKETS

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_SOCKETS
  LANGUAGES C
)

include(CheckIncludeFiles)
include(CheckStructHasMember)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_SOCKETS "Enable the sockets extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/sockets"
  PHP_EXT_SOCKETS
  "low-level socket communication interface"
)

if(NOT PHP_EXT_SOCKETS)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(sockets)

if(PHP_EXT_SOCKETS STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_sockets MODULE)
else()
  add_library(php_ext_sockets OBJECT)
endif()

target_sources(
  php_ext_sockets
  PRIVATE
    conversions.c
    multicast.c
    sendrecvmsg.c
    sockaddr_conv.c
    sockets.c
    sockets.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_sockets.h
        $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_SOURCE_DIR}/windows_common.h>
)

target_include_directories(php_ext_sockets PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(
  php_ext_sockets
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
    $<$<PLATFORM_ID:Darwin>:__APPLE_USE_RFC_3542>
    $<$<PLATFORM_ID:Windows>:PHP_SOCKETS_EXPORTS>
)

target_link_libraries(
  php_ext_sockets
  PRIVATE
    $<$<PLATFORM_ID:Windows>:ws2_32;iphlpapi>
)

include(PHP/SearchLibraries)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  php_search_libraries(
    SYMBOL hstrerror
    HEADERS netdb.h
    LIBRARIES
      resolv  # Solaris/illumos
      network # Haiku
    RESULT_VARIABLE PHP_EXT_SOCKETS_HAVE_HSTRERROR
    TARGET php_ext_sockets PRIVATE
  )
  set(HAVE_HSTRERROR ${PHP_EXT_SOCKETS_HAVE_HSTRERROR})
cmake_pop_check_state()

check_symbol_exists(if_nametoindex net/if.h PHP_EXT_SOCKETS_HAVE_IF_NAMETOINDEX)
set(HAVE_IF_NAMETOINDEX ${PHP_EXT_SOCKETS_HAVE_IF_NAMETOINDEX})

check_symbol_exists(if_indextoname net/if.h PHP_EXT_SOCKETS_HAVE_IF_INDEXTONAME)
set(HAVE_IF_INDEXTONAME ${PHP_EXT_SOCKETS_HAVE_IF_INDEXTONAME})

check_symbol_exists(sockatmark sys/socket.h PHP_EXT_SOCKETS_HAVE_SOCKATMARK)
set(HAVE_SOCKATMARK ${PHP_EXT_SOCKETS_HAVE_SOCKATMARK})

check_symbol_exists(AI_V4MAPPED netdb.h PHP_EXT_SOCKETS_HAVE_AI_V4MAPPED)
set(HAVE_AI_V4MAPPED ${PHP_EXT_SOCKETS_HAVE_AI_V4MAPPED})

check_symbol_exists(AI_ALL netdb.h PHP_EXT_SOCKETS_HAVE_AI_ALL)
set(HAVE_AI_ALL ${PHP_EXT_SOCKETS_HAVE_AI_ALL})

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(AI_IDN netdb.h PHP_EXT_SOCKETS_HAVE_AI_IDN)
  set(HAVE_AI_IDN ${PHP_EXT_SOCKETS_HAVE_AI_IDN})
cmake_pop_check_state()

check_include_files(sys/sockio.h PHP_EXT_SOCKETS_HAVE_SYS_SOCKIO_H)
set(HAVE_SYS_SOCKIO_H ${PHP_EXT_SOCKETS_HAVE_SYS_SOCKIO_H})

check_include_files(linux/filter.h PHP_EXT_SOCKETS_HAVE_LINUX_FILTER_H)
set(HAVE_LINUX_FILTER_H ${PHP_EXT_SOCKETS_HAVE_LINUX_FILTER_H})

# Check for field ss_family in sockaddr_storage (missing in AIX until 5.3).
check_struct_has_member(
  "struct sockaddr_storage"
  ss_family
  sys/socket.h
  PHP_EXT_SOCKETS_HAVE_SA_SS_FAMILY
)
set(HAVE_SA_SS_FAMILY ${PHP_EXT_SOCKETS_HAVE_SA_SS_FAMILY})

# Check for struct ucred. Checking the header is not enough. E.g. DragonFlyBSD.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  set(CMAKE_EXTRA_INCLUDE_FILES "sys/socket.h")
  check_type_size(
    "struct ucred"
    PHP_EXT_SOCKETS_SIZEOF_STRUCT_UCRED
    RESULT_VARIABLE PHP_EXT_SOCKETS_HAVE_STRUCT_UCRED
  )
cmake_pop_check_state()
set(ANC_CREDS_UCRED ${PHP_EXT_SOCKETS_HAVE_STRUCT_UCRED})

# Check for struct cmsgcred.
cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "sys/socket.h")
  check_type_size(
    "struct cmsgcred"
    PHP_EXT_SOCKETS_SIZEOF_STRUCT_CMSGCRED
    RESULT_VARIABLE PHP_EXT_SOCKETS_HAVE_STRUCT_CMSGCRED
  )
cmake_pop_check_state()
set(ANC_CREDS_CMSGCRED ${PHP_EXT_SOCKETS_HAVE_STRUCT_CMSGCRED})

set(HAVE_SOCKETS TRUE)

configure_file(cmake/config.h.in config.h)
