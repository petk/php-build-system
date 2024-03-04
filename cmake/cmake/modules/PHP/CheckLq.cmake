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

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

message(CHECK_START "Checking for TCP_INFO")

check_source_compiles(C "
  #include <netinet/tcp.h>

  int main(void) {
    struct tcp_info ti;
    int x = TCP_INFO;

    return 0;
  }
" HAVE_LQ_TCP_INFO)

if(HAVE_LQ_TCP_INFO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking for TCP_CONNECTION_INFO")

check_source_compiles(C "
  #include <netinet/tcp.h>

  int main(void) {
    struct tcp_connection_info ti;
    int x = TCP_CONNECTION_INFO;

    return 0;
  }
" HAVE_LQ_TCP_CONNECTION_INFO)

if(HAVE_LQ_TCP_CONNECTION_INFO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

if(NOT HAVE_LQ_TCP_INFO AND NOT HAVE_LQ_TCP_CONNECTION_INFO)
  message(CHECK_START "Checking for SO_LISTENQLEN")
  check_source_compiles(C "
    #include <sys/socket.h>

    int main(void) {
      int x = SO_LISTENQLIMIT;
      int y = SO_LISTENQLEN;

      return 0;
    }
  " HAVE_LQ_SO_LISTENQ)
  if(HAVE_LQ_SO_LISTENQ)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()
