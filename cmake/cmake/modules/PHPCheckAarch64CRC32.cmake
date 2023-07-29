#[=============================================================================[
Checks whether aarch64 CRC32 API is available.

Module sets the following variables:

``HAVE_AARCH64_CRC32``
  Set to 1 if aarch64 CRC32 API is available.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for aarch64 CRC32 API")

check_c_source_compiles("
  #include <arm_acle.h>

  int main (void) {
    __crc32d(0, 0);
    return 0;
  }
" have_crc32d)

if(have_crc32d)
  set(HAVE_AARCH64_CRC32 1 CACHE STRING "Define when aarch64 CRC32 API is available.")
endif()
