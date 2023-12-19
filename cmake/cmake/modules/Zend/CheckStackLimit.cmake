#[=============================================================================[
Check whether the stack grows downwards. Assumes contiguous stack.

Cache variables:

  ZEND_CHECK_STACK_LIMIT
    Whether checking the stack limit is supported.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)

message(CHECK_START "Checking whether the stack grows downwards")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

if(NOT CMAKE_CROSSCOMPILING)
  check_source_runs(C "
    #include <stdint.h>

    int (*volatile f)(uintptr_t);

    int stack_grows_downwards(uintptr_t arg) {
      int local;
      return (uintptr_t)&local < arg;
    }

    int main(void) {
      int local;

      f = stack_grows_downwards;
      return f((uintptr_t)&local) ? 0 : 1;
    }
  " ZEND_CHECK_STACK_LIMIT)
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(ZEND_CHECK_STACK_LIMIT)
  message(CHECK_PASS "yes")
elseif(CMAKE_CROSSCOMPILING)
  message(CHECK_FAIL "no (cross-compiling)")
else()
  message(CHECK_FAIL "no")
endif()
