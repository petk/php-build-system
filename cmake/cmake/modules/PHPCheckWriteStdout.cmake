#[=============================================================================[
Checks whether writing to stdout works.

The module defines the following variables if writing to STDOUT works:

``PHP_WRITE_STDOUT``
  Defined to 1 if write(2) works.
]=============================================================================]#

include(CheckCSourceRuns)

message(STATUS "Checking whether writing to stdout works")

if(CMAKE_CROSSCOMPILING)
  string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" host_os)
  if(${host_os} MATCHES ".*linux.*")
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
