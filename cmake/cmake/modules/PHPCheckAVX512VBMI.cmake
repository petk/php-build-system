#[=============================================================================[
Checks whether compiler supports AVX512 VBMI.

Module sets the following variables:

``PHP_HAVE_AVX512_VBMI_SUPPORTS``
  Set to 1 if compiler supports AVX512 VBMI, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)
include(CMakePushCheckState)

message(STATUS "Checking for AVX512 VBMI support in compiler")

cmake_push_check_state()
  set(CMAKE_REQUIRED_FLAGS "-mavx512f -mavx512cd -mavx512vl -mavx512dq -mavx512bw -mavx512vbmi ${CMAKE_REQUIRED_FLAGS}")
  check_c_source_compiles("
    #include <immintrin.h>

    int main(void) {
      __m512i mask = _mm512_set1_epi32(0x1);
      char out[32];
      _mm512_storeu_si512(out, _mm512_permutexvar_epi8(mask, mask));
      return 0;
    }
  " have_avx512_vbmi_support)
cmake_pop_check_state()

if(have_avx512_vbmi_support)
  set(have_avx512_vbmi_support 1)
else()
  set(have_avx512_vbmi_support 0)
endif()

set(PHP_HAVE_AVX512_VBMI_SUPPORTS ${have_avx512_vbmi_support} CACHE STRING "Whether the compiler supports AVX512 VBMI")
