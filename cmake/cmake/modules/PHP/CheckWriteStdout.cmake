#[=============================================================================[
Checks whether writing to stdout works.

The module defines the following variables if writing to stdout works:

PHP_WRITE_STDOUT
  Set to 1 if write(2) works.
]=============================================================================]#

include(CheckCSourceRuns)

message(STATUS "Checking whether writing to stdout works")

if(CMAKE_CROSSCOMPILING)
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(PHP_WRITE_STDOUT 1 CACHE INTERNAL "whether write(2) works")
    message(STATUS "yes")
  else()
    message(STATUS "no")
  endif()
else()
  check_c_source_runs("
    #ifdef HAVE_UNISTD_H
    # include <unistd.h>
    #endif

    #define TEXT \"This is the test message -- \"

    int main(void)
    {
      int n;

      n = write(1, TEXT, sizeof(TEXT)-1);
      return (!(n == sizeof(TEXT)-1));
    }
  " PHP_WRITE_STDOUT)
endif()
