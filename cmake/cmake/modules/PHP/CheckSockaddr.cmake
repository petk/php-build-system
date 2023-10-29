#[=============================================================================[
Check if struct sockaddr_storage exists and if field sa_len exists in struct
sockaddr.

Cache variables:

  HAVE_SOCKADDR_STORAGE
    Set to 1 if struct sockaddr_storage is available.

  HAVE_SOCKADDR_SA_LEN
    Set to 1 if struct sockaddr has field sa_len.
]=============================================================================]#

include(CheckCSourceCompiles)

message(CHECK_START "Checking for struct sockaddr_storage")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
  #include <sys/types.h>
  #include <sys/socket.h>

  int main(void) {
    struct sockaddr_storage s;
    s;

    return 0;
  }
" HAVE_SOCKADDR_STORAGE)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_SOCKADDR_STORAGE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

message(CHECK_START "Checking for field sa_len in struct sockaddr")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
  #include <sys/types.h>
  #include <sys/socket.h>

  int main(void) {
    static struct sockaddr sa;
    int n = (int) sa.sa_len;

    return n;
  }
" HAVE_SOCKADDR_SA_LEN)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_SOCKADDR_SA_LEN)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
