#[=============================================================================[
Check for asm goto support.

Cache variables:

  HAVE_ASM_GOTO
    Set to 1 if asm goto is supported.
]=============================================================================]#

include(CheckCSourceCompiles)
include(CheckCSourceRuns)

message(CHECK_START "Checking for asm goto support")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

if(CMAKE_CROSSCOMPILING)
  check_c_source_compiles("
    int main(void) {
      #if defined(__x86_64__) || defined(__i386__)
        __asm__ goto(\"jmp %l0\\\\n\" :::: end);
      #elif defined(__aarch64__)
        __asm__ goto(\"b %l0\\\\n\" :::: end);
      #endif
      end:
        return 0;
    }
  " HAVE_ASM_GOTO)
else()
  check_c_source_runs("
    int main(void) {
      #if defined(__x86_64__) || defined(__i386__)
        __asm__ goto(\"jmp %l0\\\\n\" :::: end);
      #elif defined(__aarch64__)
        __asm__ goto(\"b %l0\\\\n\" :::: end);
      #endif
      end:
        return 0;
    }
  " HAVE_ASM_GOTO)
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_ASM_GOTO)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
