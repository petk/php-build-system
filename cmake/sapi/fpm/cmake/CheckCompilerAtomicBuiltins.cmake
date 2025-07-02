#[=============================================================================[
Check for compiler atomic builtins.

Result variables:

* HAVE_BUILTIN_ATOMIC
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

set(HAVE_BUILTIN_ATOMIC FALSE)

# Skip in consecutive configuration phases.
if(DEFINED PHP_SAPI_FPM_HAS_BUILTIN_ATOMIC)
  if(PHP_SAPI_FPM_HAS_BUILTIN_ATOMIC)
    set(HAVE_BUILTIN_ATOMIC TRUE)
  endif()
  return()
endif()

message(CHECK_START "Checking if compiler has __sync_bool_compare_and_swap")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    int main(void)
    {
      int variable = 1;
      return (__sync_bool_compare_and_swap(&variable, 1, 2)
            && __sync_add_and_fetch(&variable, 1)) ? 1 : 0;
    }
  ]] PHP_SAPI_FPM_HAS_BUILTIN_ATOMIC)
cmake_pop_check_state()

if(PHP_SAPI_FPM_HAS_BUILTIN_ATOMIC)
  set(HAVE_BUILTIN_ATOMIC TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
