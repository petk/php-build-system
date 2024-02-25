include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckStructHasMember)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_SOCKETS "Enable the sockets extension" OFF)

add_feature_info(
  "ext/sockets"
  EXT_SOCKETS
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

target_sources(
  php_sockets
  PRIVATE
    conversions.c
    multicast.c
    sendrecvmsg.c
    sockaddr_conv.c
    sockets.c
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        php_sockets.h
        $<$<PLATFORM_ID:Windows>:windows_common.h>
)

target_compile_definitions(
  php_sockets
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<PLATFORM_ID:Darwin>:__APPLE_USE_RFC_3542>
    # TODO: Should this be added for shared sockets extension only?
    $<$<PLATFORM_ID:Windows>:PHP_SOCKETS_EXPORTS>
)

target_link_libraries(
  php_sockets
  PRIVATE
    $<$<PLATFORM_ID:Windows>:ws2_32;iphlpapi>
)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(hstrerror "netdb.h;sys/socket.h" HAVE_HSTRERROR)
cmake_pop_check_state()

check_symbol_exists(if_nametoindex "net/if.h" HAVE_IF_NAMETOINDEX)
check_symbol_exists(if_indextoname "net/if.h" HAVE_IF_INDEXTONAME)
check_symbol_exists(sockatmark "sys/socket.h" HAVE_SOCKATMARK)

check_include_file(sys/sockio.h HAVE_SYS_SOCKIO_H)
check_include_file(linux/filter.h HAVE_LINUX_FILTER_H)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  check_include_file(winsock.h _HAVE_WINSOCK_H)
  if(NOT _HAVE_WINSOCK_H)
    message(
      FATAL_ERROR
      "Required file winsock.h is missing for the socket extension."
    )
  endif()
endif()

# Check for field ss_family in sockaddr_storage (missing in AIX until 5.3).
check_struct_has_member("struct sockaddr_storage" ss_family sys/socket.h HAVE_STRUCT_SOCKADDR_STORAGE_SS_FAMILY)

message(CHECK_START "Checking if getaddrinfo supports AI_V4MAPPED")
check_source_compiles(C "
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
check_source_compiles(C "
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

  check_source_compiles(C "
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

# Check for struct ucred. Checking the header is not enough. E.g. DragonFlyBSD.
message(CHECK_START "Checking if ancillary credentials uses ucred")
check_source_compiles(C "
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
cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "sys/socket.h")
  check_type_size("struct cmsgcred" CMSGCRED)
cmake_pop_check_state()
if(CMSGCRED)
  set(
    ANC_CREDS_CMSGCRED 1
    CACHE INTERNAL "Define to 1 if the system has the type 'struct cmsgcred'."
  )
endif()

install(
  TARGETS php_sockets
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
