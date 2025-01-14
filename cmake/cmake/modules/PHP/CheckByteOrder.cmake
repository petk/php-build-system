#[=============================================================================[
# PHP/CheckByteOrder

Check whether system byte ordering is big-endian.

## Cache variables

* `WORDS_BIGENDIAN`
#]=============================================================================]

include_guard(GLOBAL)

# Skip in consecutive configuration phases.
if(DEFINED WORDS_BIGENDIAN)
  return()
endif()

include(CheckSourceRuns)

message(CHECK_START "Checking byte ordering")

if(CMAKE_C_BYTE_ORDER STREQUAL "BIG_ENDIAN")
  message(CHECK_PASS "big-endian")
  set(
    WORDS_BIGENDIAN
    TRUE
    CACHE INTERNAL
    "Whether byte ordering is big-endian."
  )
elseif(CMAKE_C_BYTE_ORDER STREQUAL "LITTLE_ENDIAN")
  set(
    WORDS_BIGENDIAN
    FALSE
    CACHE INTERNAL
    "Whether byte ordering is big-endian."
  )
  message(CHECK_PASS "little-endian")
else()
  if(
    NOT DEFINED WORDS_BIGENDIAN_EXITCODE
    AND CMAKE_CROSSCOMPILING
    AND NOT CMAKE_CROSSCOMPILING_EMULATOR
  )
    message(
      NOTICE
      "Byte ordering could not be detected, assuming the target system is "
      "little-endian. Set 'WORDS_BIGENDIAN_EXITCODE' to '0' if targeting a "
      "big-endian system."
    )
    set(WORDS_BIGENDIAN_EXITCODE 1)
  endif()

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

  if(WORDS_BIGENDIAN)
    message(CHECK_PASS "big-endian")
  else()
    message(CHECK_PASS "little-endian")
  endif()
endif()
