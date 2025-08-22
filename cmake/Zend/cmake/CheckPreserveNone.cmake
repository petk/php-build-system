#[=============================================================================[
Check if the 'preserve_none' calling convention is supported and matches PHP's
expectations.

The 'preserve_none' support is available in Clang 19 and newer.

Result variables:

* HAVE_PRESERVE_NONE
#]=============================================================================]

include(CheckSourceRuns)
include(CMakePushCheckState)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_PRESERVE_NONE FALSE)
  return()
endif()

# Skip in consecutive configuration phases.
if(NOT DEFINED PHP_ZEND_HAVE_PRESERVE_NONE)
  message(CHECK_START "Checking for preserve_none calling convention")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_runs(C [[
      #include <stdio.h>
      #include <stdint.h>

      const char * const1 = "str1";
      const char * const2 = "str2";
      const char * const3 = "str3";
      uint64_t key = UINT64_C(0x9d7f71d2bd296364);

      uintptr_t _a = 0;
      uintptr_t _b = 0;

      uintptr_t __attribute__((preserve_none)) fun(uintptr_t a, uintptr_t b)
      {
        _a = a;
        _b = b;
        return (uintptr_t)const3;
      }

      uintptr_t __attribute__((preserve_none)) test(void)
      {
        uintptr_t ret;

      #if defined(__x86_64__)
        __asm__ __volatile__(
          /* XORing to make it unlikely the value exists in any other register */
          "movq %1, %%r12\n"
          "xorq %3, %%r12\n"
          "movq %2, %%r13\n"
          "xorq %3, %%r13\n"
          "xorq %%rax, %%rax\n"
          "call fun\n"
          : "=a" (ret)
          : "r" (const1), "r" (const2), "r" (key)
          : "r12", "r13"
        );
      #elif defined(__aarch64__)
        __asm__ __volatile__(
          /* XORing to make it unlikely the value exists in any other register */
          "eor    x20, %1, %3\n"
          "eor    x21, %2, %3\n"
          "eor    x0, x0, x0\n"
          "bl     fun\n"
          "mov    %0, x0\n"
          "=r" (ret)
          "r" (const1), "r" (const2), "r" (key)
          : "x0", "x21", "x22", "x30"
        );
      #else
      # error
      #endif

        return ret;
      }

      int main(void)
      {
        /* JIT is making the following expectations about preserve_none:
         * - The registers used for integer args 1 and 2
         * - The register used for a single integer return value
         *
         * We check these expectations here:
         */

        uintptr_t ret = test();

        if (_a != ((uintptr_t)const1 ^ key)) {
          fprintf(stderr, "arg1 mismatch\n");
          return 1;
        }
        if (_b != ((uintptr_t)const2 ^ key)) {
          fprintf(stderr, "arg2 mismatch\n");
          return 2;
        }
        if (ret != (uintptr_t)const3) {
          fprintf(stderr, "ret mismatch\n");
          return 3;
        }

        fprintf(stderr, "OK\n");

        return 0;
      }
    ]] PHP_ZEND_HAVE_PRESERVE_NONE)
  cmake_pop_check_state()

  if(PHP_ZEND_HAVE_PRESERVE_NONE)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

set(HAVE_PRESERVE_NONE ${PHP_ZEND_HAVE_PRESERVE_NONE})
