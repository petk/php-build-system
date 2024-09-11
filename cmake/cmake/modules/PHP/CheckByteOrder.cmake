#[=============================================================================[
Check whether system byte ordering is big-endian.

Cache variables:

  WORDS_BIGENDIAN
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)

message(CHECK_START "Checking byte ordering")

if(CMAKE_C_BYTE_ORDER STREQUAL "BIG_ENDIAN")
  message(CHECK_PASS "big-endian")
  set(WORDS_BIGENDIAN 1 CACHE INTERNAL "Whether byte ordering is big-endian.")
elseif(CMAKE_C_BYTE_ORDER STREQUAL "LITTLE_ENDIAN")
  message(CHECK_PASS "little-endian")
else()
  if(NOT CMAKE_CROSSCOMPILING OR CMAKE_CROSSCOMPILING_EMULATOR)
    check_source_runs(C [[
      int main(void)
      {
        short one = 1;
        char *cp = (char *)&one;

        if (*cp == 0) {
          return 0;
        }

        return 1;
      }
    ]] WORDS_BIGENDIAN)
  endif()

  if(WORDS_BIGENDIAN)
    message(CHECK_PASS "big-endian")
  elseif(DEFINED WORDS_BIGENDIAN)
    message(CHECK_PASS "little-endian")
  else()
    message(CHECK_FAIL "unknown (cross-compiling)")
    message(
      WARNING
      "Byte ordering could not be detected, assuming system is little-endian. "
      "Set 'WORDS_BIGENDIAN' to 'ON' if targeting a big-endian system."
    )
  endif()
endif()
