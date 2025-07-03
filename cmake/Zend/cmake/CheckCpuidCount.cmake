#[=============================================================================[
Check for the __cpuid_count support.

Result variables:

* HAVE_CPUID_COUNT
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

set(HAVE_CPUID_COUNT FALSE)

# Skip in consecutive configuration phases.
if(DEFINED PHP_ZEND_HAS_CPUID_COUNT)
  if(PHP_ZEND_HAS_CPUID_COUNT)
    set(HAVE_CPUID_COUNT TRUE)
  endif()
  return()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

message(CHECK_START "Checking whether __cpuid_count is available")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    #include <cpuid.h>
    int main(void)
    {
      unsigned eax, ebx, ecx, edx;
      __cpuid_count(0, 0, eax, ebx, ecx, edx);
      return 0;
    }
  ]] PHP_ZEND_HAS_CPUID_COUNT)
cmake_pop_check_state()

if(PHP_ZEND_HAS_CPUID_COUNT)
  set(HAVE_CPUID_COUNT TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
