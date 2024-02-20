#[=============================================================================[
Check for asm goto support.

Cache variables:

  HAVE_ASM_GOTO
    Whether asm goto is supported.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CheckSourceRuns)
include(CMakePushCheckState)

message(CHECK_START "Checking for asm goto support")

block()
  set(source [[
    int main(void) {
      #if defined(__x86_64__) || defined(__i386__)
        __asm__ goto("jmp %l0\n" :::: end);
      #elif defined(__aarch64__)
        __asm__ goto("b %l0\n" :::: end);
      #endif
      end:
        return 0;
    }
  ]])

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    if(CMAKE_CROSSCOMPILING)
      check_source_compiles(C "${source}" HAVE_ASM_GOTO)
    else()
      check_source_runs(C "${source}" HAVE_ASM_GOTO)
    endif()
  cmake_pop_check_state()
endblock()

if(HAVE_ASM_GOTO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
