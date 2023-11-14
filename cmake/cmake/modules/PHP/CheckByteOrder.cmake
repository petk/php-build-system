#[=============================================================================[
Check whether system byte ordering is big-endian.

Cache variables:

  WORDS_BIGENDIAN
    Whether byte ordering is big-endian.
]=============================================================================]#

include(CheckCSourceRuns)

message(CHECK_START "Checking byte ordering")

if(CMAKE_C_BYTE_ORDER STREQUAL "BIG_ENDIAN")
  message(CHECK_PASS "big-endian")
  set(WORDS_BIGENDIAN 1 CACHE INTERNAL "Whether processor uses big-endian words")
elseif(CMAKE_C_BYTE_ORDER STREQUAL "LITTLE_ENDIAN")
  message(CHECK_PASS "little-endian")
else()
  if(NOT CMAKE_CROSSCOMPILING)
    check_c_source_runs("
      int main(void) {
        short one = 1;
        char *cp = (char *)&one;

        if (*cp == 0) {
          return(0);
        } else {
          return(1);
        }
      }
    " WORDS_BIGENDIAN)

    if(WORDS_BIGENDIAN)
      message(CHECK_PASS "big-endian")
    else()
      message(CHECK_FAIL "little-endian")
    endif()
  else()
    message(CHECK_FAIL "unknown (cross-compiling)")
    message(WARNING "Byte ordering could not be detected")
  endif()
endif()
