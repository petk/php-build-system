#[=============================================================================[
Check if OS can spawn processes with inherited handles.

Cache variables:

  HAVE_FORK
    Set to 1 if fork() function is available.

  HAVE_CREATEPROCESS
    Set to 1 if CreateProcess() function is available.

  PHP_CAN_SUPPORT_PROC_OPEN
    Set to 1 if system has fork/vfork/CreateProcess
]=============================================================================]#

include(CheckSymbolExists)

message(CHECK_START "Checking if system can spawn processes with inherited handles")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_symbol_exists(fork "unistd.h" HAVE_FORK)
check_symbol_exists(CreateProcess "windows.h" HAVE_CREATEPROCESS)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_FORK OR HAVE_CREATEPROCESS)
  set(
    PHP_CAN_SUPPORT_PROC_OPEN 1
    CACHE INTERNAL "Define if system has fork/vfork/CreateProcess"
  )

  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
