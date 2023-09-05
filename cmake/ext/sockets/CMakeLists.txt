include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(EXT_SOCKETS "Whether to enable the sockets extension" OFF)

cmake_dependent_option(EXT_SOCKETS_SHARED "Whether to build the sockets extension as shared object" OFF "EXT_SOCKETS;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_SOCKETS)
  return()
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(hstrerror "netdb.h;sys/socket.h" HAVE_HSTRERROR)
cmake_pop_check_state()

check_symbol_exists(if_nametoindex "net/if.h" HAVE_IF_NAMETOINDEX)
check_symbol_exists(if_indextoname "net/if.h" HAVE_IF_INDEXTONAME)
check_symbol_exists(sockatmark "sys/socket.h" HAVE_SOCKATMARK)

check_include_file(netinet/tcp.h HAVE_NETINET_TCP_H)
check_include_file(sys/un.h HAVE_SYS_UN_H)
check_include_file(sys/sockio.h HAVE_SYS_SOCKIO_H)

message(STATUS "Checking for field ss_family in struct sockaddr_storage")

check_c_source_compiles("
  #include <sys/socket.h>
  #include <sys/types.h>
  #include <netdb.h>
  int main() {
    struct sockaddr_storage sa_store;
    sa_store.ss_family = AF_INET6;

    return 0;
  }
" HAVE_SA_SS_FAMILY)

message(STATUS "Checking if getaddrinfo supports AI_V4MAPPED")

check_c_source_compiles("
  #include <netdb.h>

  int main() {
    int flag = AI_V4MAPPED;
    return 0;
  }
" HAVE_AI_V4MAPPED)

message(STATUS "Checking if getaddrinfo supports AI_ALL")

check_c_source_compiles("
  #include <netdb.h>

  int main() {
    int flag = AI_ALL;

    return 0;
  }
" HAVE_AI_ALL)

message(STATUS "Checking if getaddrinfo supports AI_IDN")

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

message(STATUS "Checking if ancillary credentials uses ucred")

check_c_source_compiles("
  #ifndef _GNU_SOURCE
  #define _GNU_SOURCE
  #endif
  #include <sys/socket.h>

  int main() {
    struct ucred u = {.gid = 0};

    return 0;
  }
" ANC_CREDS_UCRED)

message(STATUS "Checking if ancillary credentials uses cmsgcred")

check_c_source_compiles("
  #include <sys/socket.h>
  int main() {
    struct cmsgcred c = {0};

    return 0;
  }
" ANC_CREDS_CMSGCRED)

if(EXT_SOCKETS_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME sockets ${_library_type})

add_library(ext_sockets ${_library_type}
  sockets.c
  multicast.c
  conversions.c
  sockaddr_conv.c
  sendrecvmsg.c
)

target_compile_definitions(ext_sockets PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

string(TOLOWER "${CMAKE_HOST_SYSTEM}" host_os)
if(${host_os} MATCHES ".*darwin.*")
  target_compile_definitions(ext_sockets PRIVATE __APPLE_USE_RFC_3542)
endif()

file(GLOB SOCKETS_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
set_target_properties(ext_sockets PROPERTIES PUBLIC_HEADER "${SOCKETS_HEADER_FILES}")
