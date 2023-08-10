#[=============================================================================[
Checks if OS can spawn processes with inherited handles.

The module sets the following variables:

``HAVE_FORK``
  Set to 1 if fork() function is available.
``HAVE_CREATEPROCESS``
  Set to 1 if CreateProcess() function is available.
``PHP_CAN_SUPPORT_PROC_OPEN``
  Set to 1 if system has fork/vfork/CreateProcess
]=============================================================================]#

include(CheckSymbolExists)

check_symbol_exists(fork "unistd.h" HAVE_FORK)
check_symbol_exists(CreateProcess "windows.h" HAVE_CREATEPROCESS)

message(STATUS "Checking if your OS can spawn processes with inherited handles")

if(HAVE_FORK OR HAVE_CREATEPROCESS)
  message(STATUS "yes")
  set(PHP_CAN_SUPPORT_PROC_OPEN 1 CACHE INTERNAL "Define if your system has fork/vfork/CreateProcess")
else()
  message(STATUS "no")
endif()
