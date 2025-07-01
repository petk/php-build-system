#[=============================================================================[
Check whether the stack grows downwards. Assumes contiguous stack.

Result/cache variables:

* ZEND_CHECK_STACK_LIMIT - Whether checking the stack limit is supported.
#]=============================================================================]

include_guard(GLOBAL)

# Skip in consecutive configuration phases.
if(DEFINED ZEND_CHECK_STACK_LIMIT)
  return()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(ZEND_CHECK_STACK_LIMIT TRUE)
  return()
endif()

include(CheckSourceRuns)
include(CMakePushCheckState)

message(CHECK_START "Checking whether the stack grows downwards")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_runs(C [[
    #include <stdint.h>

    #ifdef __has_builtin
    # if __has_builtin(__builtin_frame_address)
    #  define builtin_frame_address __builtin_frame_address(0)
    # endif
    #endif

    int (*volatile f)(uintptr_t);

    int stack_grows_downwards(uintptr_t arg)
    {
    #ifdef builtin_frame_address
      uintptr_t addr = (uintptr_t)builtin_frame_address;
    #else
      int local;
      uintptr_t addr = (uintptr_t)&local;
    #endif

      return addr < arg;
    }

    int main(void)
    {
    #ifdef builtin_frame_address
      uintptr_t addr = (uintptr_t)builtin_frame_address;
    #else
      int local;
      uintptr_t addr = (uintptr_t)&local;
    #endif

      f = stack_grows_downwards;
      return f(addr) ? 0 : 1;
    }
  ]] ZEND_CHECK_STACK_LIMIT)
cmake_pop_check_state()

if(ZEND_CHECK_STACK_LIMIT)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
