#[=============================================================================[
Check whether the stack grows downwards. Assumes contiguous stack.

Result variables:

* ZEND_CHECK_STACK_LIMIT
#]=============================================================================]

include(CheckSourceRuns)
include(CMakePushCheckState)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(ZEND_CHECK_STACK_LIMIT TRUE)
  return()
endif()

# Skip in consecutive configuration phases.
if(NOT DEFINED PHP_ZEND_CHECK_STACK_LIMIT)
  message(CHECK_START "Checking whether the stack grows downwards")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_runs(C [[
      #include <stdint.h>

      int (*volatile f)(uintptr_t);

      int stack_grows_downwards(uintptr_t arg)
      {
        int local;
        return (uintptr_t)&local < arg;
      }

      int main(void)
      {
        int local;

        f = stack_grows_downwards;
        return f((uintptr_t)&local) ? 0 : 1;
      }
    ]] PHP_ZEND_CHECK_STACK_LIMIT)
  cmake_pop_check_state()

  if(PHP_ZEND_CHECK_STACK_LIMIT)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

set(ZEND_CHECK_STACK_LIMIT ${PHP_ZEND_CHECK_STACK_LIMIT})
