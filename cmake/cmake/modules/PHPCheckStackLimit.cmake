#[=============================================================================[
Checks whether the stack grows downwards. Assumes contiguous stack.

The module defines the following variables:

``ZEND_CHECK_STACK_LIMIT``
  Defined to 1 if checking the stack limit is supported.
]=============================================================================]#

include(CheckCSourceRuns)

message(STATUS "Checking whether the stack grows downwards")

check_c_source_runs("
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

if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: No")
elseif(NOT ZEND_CHECK_STACK_LIMIT)
  message(STATUS "no")
else()
  set(ZEND_CHECK_STACK_LIMIT 1 CACHE STRING "Define if checking the stack limit is supported")
  message(STATUS "yes")
endif()
