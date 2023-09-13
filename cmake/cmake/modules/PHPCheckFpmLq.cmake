#[=============================================================================[
Checks for tcp_info.

The module sets the following variables if checks are successful:

HAVE_LQ_TCP_INFO
  Set to 1 if TCP_INFO is present.

HAVE_LQ_TCP_CONNECTION_INFO
  Set to 1 if TCP_CONNECTION_INFO is present.

HAVE_LQ_SO_LISTENQ
  Set to 1 if SO_LISTENQLEN is available as alternative to TCP_INFO and
  TCP_CONNECTION_INFO.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CMakePushCheckState)

check_c_source_compiles("
  #include <netinet/tcp.h>

  int main(void) {
    struct tcp_info ti;
    int x = TCP_INFO;

    return 0;
  }
" HAVE_LQ_TCP_INFO)

check_c_source_compiles("
  #include <netinet/tcp.h>

  int main(void) {
    struct tcp_connection_info ti;
    int x = TCP_CONNECTION_INFO;

    return 0;
  }
" HAVE_LQ_TCP_CONNECTION_INFO)

if(NOT HAVE_LQ_TCP_INFO AND NOT HAVE_LQ_TCP_CONNECTION_INFO)
  check_c_source_compiles("
    #include <sys/socket.h>

    int main(void) {
      int x = SO_LISTENQLIMIT;
      int y = SO_LISTENQLEN;

      return 0;
    }
  " HAVE_LQ_SO_LISTENQ)
endif()
