#[=============================================================================[
Check whether the C compiler has support for the asm goto.

Result variables:

* HAVE_ASM_GOTO
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

set(HAVE_ASM_GOTO FALSE)

# Skip in consecutive configuration phases.
if(DEFINED PHP_ZEND_HAS_ASM_GOTO)
  if(PHP_ZEND_HAS_ASM_GOTO)
    set(HAVE_ASM_GOTO TRUE)
  endif()
  return()
endif()

# TODO: The check in this module otherwise passes on Windows. Should this be
# enabled on Windows?
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

message(CHECK_START "Checking for asm goto support")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_compiles(C [[
    int main(void)
    {
      #if defined(__x86_64__) || defined(__i386__)
        __asm__ goto("jmp %l0\n" :::: end);
      #elif defined(__aarch64__)
        __asm__ goto("b %l0\n" :::: end);
      #endif
      end:
        return 0;
    }
  ]] PHP_ZEND_HAS_ASM_GOTO)
cmake_pop_check_state()

if(PHP_ZEND_HAS_ASM_GOTO)
  set(HAVE_ASM_GOTO TRUE)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
