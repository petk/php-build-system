#[=============================================================================[
Checks for strerror_r, and if its a POSIX-compatible or a GNU specific version.

The module sets the following variables:

``HAVE_STRERROR_R``
  Set to 1 if strerror_r is available.
``STRERROR_R_CHAR_P``
  Set to 1 if strerror_r returns a char * message, otherwise it returns an int
  error number.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CheckSymbolExists)
include(CMakePushCheckState)

check_symbol_exists(strerror_r "string.h" HAVE_STRERROR_R)

if(NOT HAVE_STRERROR_R)
  return()
endif()

cmake_push_check_state()
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -D_GNU_SOURCE")
  check_c_source_compiles("
    #include <string.h>

    int main() {
      char buf[100];
      char x = *strerror_r (0, buf, sizeof buf);
      char *p = strerror_r (0, buf, sizeof buf);
      return !p || x;
    }
  " STRERROR_R_CHAR_P)
cmake_pop_check_state()
