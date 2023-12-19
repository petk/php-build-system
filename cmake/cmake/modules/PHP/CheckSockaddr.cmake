#[=============================================================================[
Check if struct sockaddr_storage exists and struct sockaddr has field sa_len.

Cache variables:

  HAVE_SOCKADDR_STORAGE
    Whether struct sockaddr_storage is available.
  HAVE_SOCKADDR_SA_LEN
    Whether struct sockaddr has field sa_len.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CheckStructHasMember)

message(CHECK_START "Checking for struct sockaddr_storage")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_source_compiles(C "
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

check_struct_has_member(
  "struct sockaddr"
  sa_len
  "sys/types.h;sys/socket.h"
  HAVE_SOCKADDR_SA_LEN
)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_SOCKADDR_SA_LEN)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
