#[=============================================================================[
Checks whether compiler supports AVX512.

Module sets the following variables:

PHP_HAVE_AVX512_SUPPORTS
  Set to true if compiler supports AVX512, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)
include(CMakePushCheckState)

message(STATUS "Checking for AVX512 support in compiler")

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_FLAGS "-mavx512f -mavx512cd -mavx512vl -mavx512dq -mavx512bw")
  check_c_source_compiles("
    #include <immintrin.h>

    int main(void) {
      __m512i mask = _mm512_set1_epi32(0x1);
      char out[32];
      _mm512_storeu_si512(out, _mm512_shuffle_epi8(mask, mask));
      return 0;
    }
  " PHP_HAVE_AVX512_SUPPORTS)
cmake_pop_check_state()
