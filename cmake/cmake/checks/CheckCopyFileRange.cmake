#[=============================================================================[
Check copy_file_range().

On FreeBSD, copy_file_range() works only with the undocumented flag
'0x01000000'. Until the problem is fixed properly, 'copy_file_range()' is used
only on Linux.

Result variables:

* HAVE_COPY_FILE_RANGE - Whether 'copy_file_range()' is supported.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

set(HAVE_COPY_FILE_RANGE FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

# Skip in consecutive configuration phases.
if(DEFINED PHP_HAS_COPY_FILE_RANGE)
  if(PHP_HAS_COPY_FILE_RANGE)
    set(HAVE_COPY_FILE_RANGE TRUE)
  endif()

  return()
endif()

message(CHECK_START "Checking for copy_file_range")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)

  check_source_compiles(C [[
    #ifndef __linux__
    # error "unsupported platform"
    #endif

    #include <linux/version.h>

    #if LINUX_VERSION_CODE < KERNEL_VERSION(5,3,0)
    # error "kernel too old"
    #endif

    #include <unistd.h>

    int main(void)
    {
      (void)copy_file_range(-1, 0, -1, 0, 0, 0);
      return 0;
    }
  ]] PHP_HAS_COPY_FILE_RANGE)
cmake_pop_check_state()

if(PHP_HAS_COPY_FILE_RANGE)
  set(HAVE_COPY_FILE_RANGE TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
