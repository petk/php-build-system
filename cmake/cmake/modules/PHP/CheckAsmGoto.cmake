#[=============================================================================[
Check for asm goto support.

If checks pass the module sets the following variables:

HAVE_ASM_GOTO
  Set to 1 if asm goto is supported.
]=============================================================================]#

include(CheckCSourceRuns)
include(CheckCSourceCompiles)

message(STATUS "Checking for asm goto")

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
