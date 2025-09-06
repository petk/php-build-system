#[=============================================================================[
Check for compiler atomic builtins.

Result variables:

* HAVE_BUILTIN_ATOMIC
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

# Skip in consecutive configuration phases.
if(NOT DEFINED PHP_SAPI_FPM_HAVE_BUILTIN_ATOMIC)
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
    ]] PHP_SAPI_FPM_HAVE_BUILTIN_ATOMIC)
  cmake_pop_check_state()

  if(PHP_SAPI_FPM_HAVE_BUILTIN_ATOMIC)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

set(HAVE_BUILTIN_ATOMIC ${PHP_SAPI_FPM_HAVE_BUILTIN_ATOMIC})
