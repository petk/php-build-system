#[=============================================================================[
Test and set the alignment define for ZEND_MM. This also does the logarithmic
test for ZEND_MM.

Cache variables:

  ZEND_MM_ALIGNMENT

  ZEND_MM_ALIGNMENT_LOG2

  ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT
]=============================================================================]#

message(CHECK_START "Checking for MM alignment and log values")

if(NOT CMAKE_CROSSCOMPILING)
  try_run(
    ZEND_MM_RUN_RESULT
    ZEND_MM_COMPILE_RESULT
    SOURCE_FROM_CONTENT src.c "
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

      int main(void) {
        size_t i = ZEND_MM_ALIGNMENT;
        int zeros = 0;

        while (i & ~0x1) {
          zeros++;
          i = i >> 1;
        }

        printf(\"(size_t)%zu (size_t)%d %d\\n\", ZEND_MM_ALIGNMENT, zeros, ZEND_MM_ALIGNMENT < 4);

        return 0;
      }
    "
    RUN_OUTPUT_STDOUT_VARIABLE ZEND_MM_OUTPUT
  )

  if(ZEND_MM_RUN_RESULT EQUAL 0 AND ZEND_MM_COMPILE_RESULT)
    message(CHECK_PASS "done")

    string(STRIP "${ZEND_MM_OUTPUT}" ZEND_MM_OUTPUT)
    string(REPLACE " " ";" ZEND_MM_OUTPUT "${ZEND_MM_OUTPUT}")

    list(GET ZEND_MM_OUTPUT 0 _zend_mm_alignment)
    list(GET ZEND_MM_OUTPUT 1 _zend_mm_alignment_log2)
    list(GET ZEND_MM_OUTPUT 2 _zend_mm_need_eight_byte_realignment)
  else()
    message(CHECK_FAIL "failed")
    message(WARNING "MM alignment values were not set")
  endif()
else()
  message(CHECK_FAIL "Cross-compiling")

  set(_zend_mm_alignment 8)
  set(_zend_mm_alignment_log2 3)
  set(_zend_mm_need_eight_byte_realignment 0)
endif()

set(
  ZEND_MM_ALIGNMENT ${_zend_mm_alignment}
  CACHE INTERNAL "Alignment for Zend memory allocator"
)
set(
  ZEND_MM_ALIGNMENT_LOG2 ${_zend_mm_alignment_log2}
  CACHE INTERNAL "Alignment for Zend memory allocator log2"
)
set(
  ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT ${_zend_mm_need_eight_byte_realignment}
  CACHE INTERNAL "Whether 8-byte realignment is needed"
)

unset(_zend_mm_alignment)
unset(_zend_mm_alignment_log2)
unset(_zend_mm_need_eight_byte_realignment)

message(STATUS
  "MM alignment values:\n"
  "    ZEND_MM_ALIGNMENT=${ZEND_MM_ALIGNMENT}\n"
  "    ZEND_MM_ALIGNMENT_LOG2=${ZEND_MM_ALIGNMENT_LOG2}\n"
  "    ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT=${ZEND_MM_NEED_EIGHT_BYTE_REALIGNMENT}"
)
