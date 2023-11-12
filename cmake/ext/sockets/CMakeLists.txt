include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_SOCKETS "Enable the sockets extension" OFF)

add_feature_info("ext/sockets" EXT_SOCKETS
  "Support for a low-level socket communication interface."
)

cmake_dependent_option(
  EXT_SOCKETS_SHARED
  "Build the sockets extension as a shared library"
  OFF
  "EXT_SOCKETS;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SOCKETS)
  return()
endif()

if(EXT_SOCKETS_SHARED)
  add_library(php_sockets SHARED)
else()
  add_library(php_sockets)
endif()

target_sources(php_sockets PRIVATE
  conversions.c
  multicast.c
  sendrecvmsg.c
  sockaddr_conv.c
  sockets.c
)

target_compile_definitions(php_sockets PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(hstrerror "netdb.h;sys/socket.h" HAVE_HSTRERROR)
cmake_pop_check_state()

check_symbol_exists(if_nametoindex "net/if.h" HAVE_IF_NAMETOINDEX)
check_symbol_exists(if_indextoname "net/if.h" HAVE_IF_INDEXTONAME)
check_symbol_exists(sockatmark "sys/socket.h" HAVE_SOCKATMARK)

check_include_file(sys/sockio.h HAVE_SYS_SOCKIO_H)
check_include_file(linux/filter.h HAVE_LINUX_FILTER_H)

message(CHECK_START "Checking for field ss_family in struct sockaddr_storage")

check_c_source_compiles("
  #include <sys/socket.h>
  #include <sys/types.h>
  #include <netdb.h>

  int main(void) {
    struct sockaddr_storage sa_store;
    sa_store.ss_family = AF_INET6;

    return 0;
  }
" HAVE_SA_SS_FAMILY)

if(HAVE_SA_SS_FAMILY)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking if getaddrinfo supports AI_V4MAPPED")

check_c_source_compiles("
  #include <netdb.h>

  int main(void) {
    int flag = AI_V4MAPPED;
    return 0;
  }
" HAVE_AI_V4MAPPED)

if(HAVE_AI_V4MAPPED)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking if getaddrinfo supports AI_ALL")

check_c_source_compiles("
  #include <netdb.h>

  int main(void) {
    int flag = AI_ALL;

    return 0;
  }
" HAVE_AI_ALL)

if(HAVE_AI_ALL)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking if getaddrinfo supports AI_IDN")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)

  check_c_source_compiles("
    #include <netdb.h>

    int main(void) {
      int flag = AI_IDN;

      return 0;
    }
  " HAVE_AI_IDN)
cmake_pop_check_state()

if(HAVE_AI_IDN)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Checking for struct ucred. Checking the header is not enough.
# E.g. DragonFlyBSD.
message(CHECK_START "Checking if ancillary credentials uses ucred")

check_c_source_compiles("
  #ifndef _GNU_SOURCE
  #define _GNU_SOURCE
  #endif
  #include <sys/socket.h>

  int main(void) {
    struct ucred u = {.gid = 0};

    return 0;
  }
" ANC_CREDS_UCRED)

if(ANC_CREDS_UCRED)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# Check for struct cmsgcred.
message(CHECK_START "Checking if ancillary credentials uses cmsgcred")

check_c_source_compiles("
  #include <sys/socket.h>
  int main(void) {
    struct cmsgcred c = {0};

    return 0;
  }
" ANC_CREDS_CMSGCRED)

if(ANC_CREDS_CMSGCRED)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

target_compile_definitions(
  php_sockets
  PRIVATE $<$<PLATFORM_ID:Darwin>:__APPLE_USE_RFC_3542>
)

target_sources(
  php_sockets
  PUBLIC FILE_SET sockets_headers
  TYPE HEADERS
  FILES php_sockets.h
)

install(
  TARGETS php_sockets
  FILE_SET sockets_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/sockets
)
