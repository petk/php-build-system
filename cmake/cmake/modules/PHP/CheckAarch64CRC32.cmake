#[=============================================================================[
Check whether aarch64 CRC32 API is available.

Cache variables:

  HAVE_AARCH64_CRC32
    Whether aarch64 CRC32 API is available.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)

message(CHECK_START "Checking for aarch64 CRC32 API availability")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_source_compiles(C "
  #include <arm_acle.h>

  int main(void) {
    __crc32d(0, 0);

    return 0;
  }
" HAVE_AARCH64_CRC32)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_AARCH64_CRC32)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
