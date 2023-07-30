#[=============================================================================[
On FreeBSD, copy_file_range() works only with the undocumented flag 0x01000000.
Until the problem is fixed properly, copy_file_range() is used only on Linux.

If checks pass the module sets the following variables:

``HAVE_COPY_FILE_RANGE``
  Set to 1 if copy_file_range() is supported.
]=============================================================================]#

include(CheckCSourceRuns)

message(STATUS "Checking for copy_file_range")

if(CMAKE_CROSSCOMPILING)
  set(HAVE_COPY_FILE_RANGE OFF)
else()
  check_c_source_runs("
    #ifdef __linux__
    #ifndef _GNU_SOURCE
    #define _GNU_SOURCE
    #endif
    #include <linux/version.h>
    #include <unistd.h>

    int main(void) {
    (void)copy_file_range(-1, 0, -1, 0, 0, 0);
    #if LINUX_VERSION_CODE < KERNEL_VERSION(5,3,0)
    #error \"kernel too old\"
    #else
    return 0;
    #endif
    }
    #else
    #error \"unsupported platform\"
    #endif
  " HAVE_COPY_FILE_RANGE)
endif()

if(HAVE_COPY_FILE_RANGE)
  set(HAVE_COPY_FILE_RANGE 1 CACHE STRING "Define if copy_file_range support")
endif()
