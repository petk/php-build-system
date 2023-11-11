#[=============================================================================[
Check for tcp_info.

Cache variables:

  HAVE_LQ_TCP_INFO
    Whether TCP_INFO is present.

  HAVE_LQ_TCP_CONNECTION_INFO
    Whether TCP_CONNECTION_INFO is present.

  HAVE_LQ_SO_LISTENQ
    Whether SO_LISTENQLEN is available as alternative to TCP_INFO and
    TCP_CONNECTION_INFO.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CMakePushCheckState)

message(CHECK_START "Checking for TCP_INFO")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
  #include <netinet/tcp.h>

  int main(void) {
    struct tcp_info ti;
    int x = TCP_INFO;

    return 0;
  }
" HAVE_LQ_TCP_INFO)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_LQ_TCP_INFO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking for TCP_CONNECTION_INFO")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
  #include <netinet/tcp.h>

  int main(void) {
    struct tcp_connection_info ti;
    int x = TCP_CONNECTION_INFO;

    return 0;
  }
" HAVE_LQ_TCP_CONNECTION_INFO)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_LQ_TCP_CONNECTION_INFO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

if(NOT HAVE_LQ_TCP_INFO AND NOT HAVE_LQ_TCP_CONNECTION_INFO)
  message(CHECK_START "Checking for SO_LISTENQLEN")

  list(APPEND CMAKE_MESSAGE_INDENT "  ")

  check_c_source_compiles("
    #include <sys/socket.h>

    int main(void) {
      int x = SO_LISTENQLIMIT;
      int y = SO_LISTENQLEN;

      return 0;
    }
  " HAVE_LQ_SO_LISTENQ)

  list(POP_BACK CMAKE_MESSAGE_INDENT)

  if(HAVE_LQ_SO_LISTENQ)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()
