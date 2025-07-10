#[=============================================================================[
Check FPM listening queue implementation.

Result variables:

* HAVE_LQ_TCP_INFO - Whether TCP_INFO is present.
* HAVE_LQ_TCP_CONNECTION_INFO - Whether TCP_CONNECTION_INFO is present.
* HAVE_LQ_SO_LISTENQ - Whether SO_LISTENQLEN and SO_LISTENQLIMIT are available
  as alternative to TCP_INFO and TCP_CONNECTION_INFO.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(PHP/SystemExtensions)

function(_php_sapi_fpm_check_lq_tcp_info result)
  cmake_push_check_state(RESET)
    # Requires _DEFAULT_SOURCE, which is enabled by _GNU_SOURCE.
    set(CMAKE_REQUIRED_LIBRARIES PHP::SystemExtensions)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C [[
      #include <netinet/tcp.h>

      int main(void)
      {
        struct tcp_info ti;
        int x = TCP_INFO;
        (void)ti;
        (void)x;

        return 0;
      }
    ]] PHP_SAPI_FPM_HAS_LQ_TCP_INFO)
  cmake_pop_check_state()

  set(${result} ${PHP_SAPI_FPM_HAS_LQ_TCP_INFO})

  return(PROPAGATE ${result})
endfunction()

# For macOS.
function(_php_sapi_fpm_check_lq_tcp_connection_info result)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C [[
      #include <netinet/tcp.h>

      int main(void)
      {
        struct tcp_connection_info ti;
        int x = TCP_CONNECTION_INFO;
        (void)ti;
        (void)x;

        return 0;
      }
    ]] PHP_SAPI_FPM_HAS_LQ_TCP_CONNECTION_INFO)
  cmake_pop_check_state()

  set(${result} ${PHP_SAPI_FPM_HAS_LQ_TCP_CONNECTION_INFO})

  return(PROPAGATE ${result})
endfunction()

# For FreeBSD.
function(_php_sapi_fpm_check_lq_so_listenq result)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C [[
      #include <sys/socket.h>

      int main(void)
      {
        int x = SO_LISTENQLIMIT;
        int y = SO_LISTENQLEN;
        (void)x;
        (void)y;

        return 0;
      }
    ]] PHP_SAPI_FPM_HAS_LQ_SO_LISTENQ)
  cmake_pop_check_state()

  set(${result} ${PHP_SAPI_FPM_HAS_LQ_SO_LISTENQ})

  return(PROPAGATE ${result})
endfunction()

message(CHECK_START "Checking FPM listening queue implementation")

_php_sapi_fpm_check_lq_tcp_info(HAVE_LQ_TCP_INFO)

if(HAVE_LQ_TCP_INFO)
  message(CHECK_PASS "TCP_INFO")
else()
  _php_sapi_fpm_check_lq_tcp_connection_info(HAVE_LQ_TCP_CONNECTION_INFO)

  if(HAVE_LQ_TCP_CONNECTION_INFO)
    message(CHECK_PASS "TCP_CONNECTION_INFO")
  else()
    _php_sapi_fpm_check_lq_so_listenq(HAVE_LQ_SO_LISTENQ)

    if(HAVE_LQ_SO_LISTENQ)
      message(CHECK_PASS "SO_LISTENQ")
    else()
      message(CHECK_FAIL "not found, FPM listening queue is disabled")
    endif()
  endif()
endif()
