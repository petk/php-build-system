#[=============================================================================[
Check whether compiler supports AVX-512.

Cache variables:

  PHP_HAVE_AVX512_SUPPORTS
    Whether compiler supports AVX-512.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

message(CHECK_START "Checking for AVX-512 support in compiler")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS "-mavx512f -mavx512cd -mavx512vl -mavx512dq -mavx512bw")
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_compiles(C "
    #include <immintrin.h>

    int main(void) {
      __m512i mask = _mm512_set1_epi32(0x1);
      char out[32];
      _mm512_storeu_si512(out, _mm512_shuffle_epi8(mask, mask));

      return 0;
    }
  " PHP_HAVE_AVX512_SUPPORTS)
cmake_pop_check_state()

if(PHP_HAVE_AVX512_SUPPORTS)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
