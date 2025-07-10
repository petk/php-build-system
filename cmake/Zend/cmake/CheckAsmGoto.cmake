#[=============================================================================[
Check whether the C compiler supports the inline assembly __asm__ goto.

Result variables:

* HAVE_ASM_GOTO
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

# The check below otherwise passes on Windows but it is disabled in PHP.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_ASM_GOTO FALSE)
  return()
endif()

# Skip in consecutive configuration phases.
if(NOT DEFINED PHP_ZEND_HAS_ASM_GOTO)
  message(CHECK_START "Checking for the inline assembly __asm__ goto support")

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
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

set(HAVE_ASM_GOTO ${PHP_ZEND_HAS_ASM_GOTO})
