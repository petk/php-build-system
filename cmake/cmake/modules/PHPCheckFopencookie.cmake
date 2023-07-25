#[=============================================================================[
Checks if fopencookie is working as expected.

The module defines the following variables if checks are successful:

``HAVE_FOPENCOOKIE``
  Defined to 1 if fopencookie is present.

``COOKIE_IO_FUNCTIONS_T``
  The type for struct due to older glibc versions.

``COOKIE_SEEKER_USES_OFF64_T``
  Whether a newer seeker definition for fopencookie is available.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(CheckSymbolExists)
include(CMakePushCheckState)

cmake_push_check_state()
  set(CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS} -D_GNU_SOURCE")
  check_symbol_exists(fopencookie "stdio.h" HAVE_FOPENCOOKIE)
cmake_pop_check_state()

if(NOT HAVE_FOPENCOOKIE)
  return()
endif()

# Newer glibcs (since 2.1.2?) have a type called cookie_io_functions_t.
check_c_source_compiles("
  #define _GNU_SOURCE
  #include <stdio.h>

  int main() {
    cookie_io_functions_t cookie;
    return 0;
  }
" COMPILATION_RESULT)

if(COMPILATION_RESULT)
  set(COOKIE_IO_FUNCTIONS_T "cookie_io_functions_t")
endif()

# Even newer glibcs have a different seeker definition.
if(CMAKE_CROSSCOMPILING)
  string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" host_os)
  if(${host_os} MATCHES ".*linux.*")
    set(cookie_io_functions_use_off64_t ON)
  endif()
else()
  check_c_source_runs("
    #define _GNU_SOURCE
    #include <stdio.h>
    #include <stdlib.h>

    struct cookiedata {
      off64_t pos;
    };

    ssize_t reader(void *cookie, char *buffer, size_t size)
    { return size; }
    ssize_t writer(void *cookie, const char *buffer, size_t size)
    { return size; }
    int closer(void *cookie)
    { return 0; }
    int seeker(void *cookie, off64_t *position, int whence)
    { ((struct cookiedata*)cookie)->pos = *position; return 0; }

    cookie_io_functions_t funcs = {reader, writer, seeker, closer};

    int main(void) {
      struct cookiedata g = { 0 };
      FILE *fp = fopencookie(&g, \"r\", funcs);

      if (fp && fseek(fp, 8192, SEEK_SET) == 0 && g.pos == 8192)
        return 0;
      return 1;
    }
  " RUN_RESULT)

  if(RUN_RESULT)
    set(cookie_io_functions_use_off64_t ON)
  endif()
endif()

if(cookie_io_functions_use_off64_t)
  set(COOKIE_SEEKER_USES_OFF64_T 1 CACHE STRING "Whether newer fopencookie seeker definition is available")
endif()
