#[=============================================================================[
# The sockets extension

Configure the `sockets` extension.

This extension provides support for a low-level socket communication interface.

## PHP_EXT_SOCKETS

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SOCKETS_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionSockets
  LANGUAGES C
)

include(CheckIncludeFiles)
include(CheckStructHasMember)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_SOCKETS "Enable the sockets extension")

add_feature_info(
  "ext/sockets"
  PHP_EXT_SOCKETS
  "low-level socket communication interface"
)

cmake_dependent_option(
  PHP_EXT_SOCKETS_SHARED
  "Build the sockets extension as a shared library"
  OFF
  PHP_EXT_SOCKETS
  OFF
)

if(NOT PHP_EXT_SOCKETS)
  return()
endif()

if(PHP_EXT_SOCKETS_SHARED)
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

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(hstrerror "netdb.h;sys/socket.h" HAVE_HSTRERROR)
cmake_pop_check_state()

check_symbol_exists(if_nametoindex net/if.h HAVE_IF_NAMETOINDEX)
check_symbol_exists(if_indextoname net/if.h HAVE_IF_INDEXTONAME)
check_symbol_exists(sockatmark sys/socket.h HAVE_SOCKATMARK)

check_include_files(sys/sockio.h HAVE_SYS_SOCKIO_H)
check_include_files(linux/filter.h HAVE_LINUX_FILTER_H)
check_include_files(linux/if_ether.h HAVE_LINUX_IF_ETHER_H)
check_include_files(linux/if_packet.h HAVE_LINUX_IF_PACKET_H)
check_include_files(linux/udp.h HAVE_LINUX_UDP_H)

# Check for field ss_family in sockaddr_storage (missing in AIX until 5.3).
check_struct_has_member(
  "struct sockaddr_storage"
  ss_family
  sys/socket.h
  HAVE_STRUCT_SOCKADDR_STORAGE_SS_FAMILY
)

# Check for struct ucred. Checking the header is not enough. E.g. DragonFlyBSD.
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  set(CMAKE_EXTRA_INCLUDE_FILES "sys/socket.h")
  check_type_size("struct ucred" STRUCT_UCRED)
cmake_pop_check_state()

# Check for struct cmsgcred.
cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "sys/socket.h")
  check_type_size("struct cmsgcred" STRUCT_CMSGCRED)
cmake_pop_check_state()

set(HAVE_SOCKETS TRUE)

configure_file(cmake/config.h.in config.h)
