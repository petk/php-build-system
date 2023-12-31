#[=============================================================================[
Check whether compiler supports AVX-512 VBMI.

Cache variables:

  PHP_HAVE_AVX512_VBMI_SUPPORTS
    Whether compiler supports AVX-512 VBMI.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

message(CHECK_START "Checking for AVX-512 VBMI support in compiler")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS "-mavx512f -mavx512cd -mavx512vl -mavx512dq -mavx512bw -mavx512vbmi")

  check_source_compiles(C "
    #include <immintrin.h>

    int main(void) {
      __m512i mask = _mm512_set1_epi32(0x1);
      char out[32];
      _mm512_storeu_si512(out, _mm512_permutexvar_epi8(mask, mask));

      return 0;
    }
  " PHP_HAVE_AVX512_VBMI_SUPPORTS)
cmake_pop_check_state()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(PHP_HAVE_AVX512_VBMI_SUPPORTS)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
