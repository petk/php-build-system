#[=============================================================================[
Checks if struct sockaddr_storage exists and if field sa_len exists in struct
sockaddr.

The module sets the following variables if support is found:

HAVE_SOCKADDR_STORAGE
  Set to 1 if struct sockaddr_storage is available.

HAVE_SOCKADDR_SA_LEN
  Set to 1 if struct sockaddr has field sa_len.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for struct sockaddr_storage")

check_c_source_compiles("
  #include <sys/types.h>
  #include <sys/socket.h>

  int main(void) {
    struct sockaddr_storage s; s;
    return 0;
  }
" HAVE_SOCKADDR_STORAGE)

message(STATUS "Checking for field sa_len in struct sockaddr")

check_c_source_compiles("
  #include <sys/types.h>
  #include <sys/socket.h>

  int main(void) {
    static struct sockaddr sa;
    int n = (int) sa.sa_len;
    return n;
  }
" HAVE_SOCKADDR_SA_LEN)
