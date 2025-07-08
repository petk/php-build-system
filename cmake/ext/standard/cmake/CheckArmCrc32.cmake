#[=============================================================================[
Check whether CRC32 API is supported on ARM architecture.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

function(_php_ext_standard_check_arm_crc32 result)
  set(${result} FALSE)

  if(PHP_EXT_STANDARD_HAS_ARM_CRC32)
    set(${result} TRUE)
  endif()

  if(DEFINED PHP_EXT_STANDARD_HAS_ARM_CRC32)
    return(PROPAGATE ${result})
  endif()

  message(CHECK_START "Checking for ARM CRC32 API availability")

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "ARM64")
      set(${result} TRUE)
    endif()

    set(
      PHP_EXT_STANDARD_HAS_ARM_CRC32
      ${${result}}
      CACHE INTERNAL
      "Whether ARM has CRC32."
    )
  endif()

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C [[
      #include <arm_acle.h>
      #ifdef __GNUC__
      # ifndef __clang__
      #  pragma GCC push_options
      #  pragma GCC target ("+nothing+crc")
      # elif defined(__APPLE__)
      #  pragma clang attribute push(__attribute__((target("crc"))), apply_to=function)
      # else
      #  pragma clang attribute push(__attribute__((target("+nothing+crc"))), apply_to=function)
      # endif
      #endif
      int main(void)
      {
        __crc32d(0, 0);
        return 0;
      }
    ]] PHP_EXT_STANDARD_HAS_ARM_CRC32)
  cmake_pop_check_state()

  if(PHP_EXT_STANDARD_HAS_ARM_CRC32)
    message(CHECK_PASS "yes")
    set(${result} TRUE)
  else()
    message(CHECK_FAIL "no")
  endif()

  return(PROPAGATE ${result})
endfunction()

_php_ext_standard_check_arm_crc32(HAVE_AARCH64_CRC32)
