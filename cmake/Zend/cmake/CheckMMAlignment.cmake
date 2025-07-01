#[=============================================================================[
Test and set the alignment defines for the Zend memory manager (`ZEND_MM`). This
also does the logarithmic test.

Result variables:

* ZEND_MM_ALIGNMENT
* ZEND_MM_ALIGNMENT_LOG2
* ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT
#]=============================================================================]

include_guard(GLOBAL)

message(CHECK_START "Checking for Zend memory manager alignment and log values")

if(
  (NOT DEFINED ZEND_MM_EXITCODE OR NOT DEFINED ZEND_MM_EXITCODE__TRYRUN_OUTPUT)
  AND CMAKE_CROSSCOMPILING
  AND NOT CMAKE_CROSSCOMPILING_EMULATOR
)
  # Set some sensible defaults when cross-compiling.
  set(ZEND_MM_EXITCODE 0)
  set(ZEND_MM_EXITCODE__TRYRUN_OUTPUT "(size_t)8 (size_t)3 0")
endif()

block(
  PROPAGATE
    ZEND_MM_ALIGNMENT
    ZEND_MM_ALIGNMENT_LOG2
    ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT
)
  try_run(
    ZEND_MM_EXITCODE
    ZEND_MM_COMPILED
    SOURCE_FROM_CONTENT src.c [[
      #include <stdio.h>
      #include <stdlib.h>

      typedef union _mm_align_test {
        void *ptr;
        double dbl;
        long lng;
      } mm_align_test;

      #if (defined (__GNUC__) && __GNUC__ >= 2)
      # define ZEND_MM_ALIGNMENT (__alignof__ (mm_align_test))
      #else
      # define ZEND_MM_ALIGNMENT (sizeof(mm_align_test))
      #endif

      int main(void)
      {
        size_t i = ZEND_MM_ALIGNMENT;
        int zeros = 0;

        while (i & ~0x1) {
          zeros++;
          i = i >> 1;
        }

        printf(
          "(size_t)%zu (size_t)%d %d\n",
          ZEND_MM_ALIGNMENT,
          zeros,
          ZEND_MM_ALIGNMENT < 4
        );

        return 0;
      }
    ]]
    RUN_OUTPUT_VARIABLE ZEND_MM_OUTPUT
  )

  if(ZEND_MM_COMPILED AND ZEND_MM_EXITCODE EQUAL 0 AND ZEND_MM_OUTPUT)
    message(CHECK_PASS "Success")

    string(STRIP "${ZEND_MM_OUTPUT}" ZEND_MM_OUTPUT)
    string(REPLACE " " ";" ZEND_MM_OUTPUT "${ZEND_MM_OUTPUT}")

    list(GET ZEND_MM_OUTPUT 0 ZEND_MM_ALIGNMENT)
    list(GET ZEND_MM_OUTPUT 1 ZEND_MM_ALIGNMENT_LOG2)
    list(GET ZEND_MM_OUTPUT 2 ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT)
  else()
    message(CHECK_FAIL "Failed")
    message(
      FATAL_ERROR
      "ZEND_MM alignment values couldn't be determined.")
  endif()
endblock()

message(
  VERBOSE
  "MM alignment values:\n"
  "    ZEND_MM_ALIGNMENT=${ZEND_MM_ALIGNMENT}\n"
  "    ZEND_MM_ALIGNMENT_LOG2=${ZEND_MM_ALIGNMENT_LOG2}\n"
  "    ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT=${ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT}"
)
