#[=============================================================================[
Check whether compiler supports AVX-512 extensions. Note that this is a compiler
check, not a runtime check where further adjustments are done in the php-src C
code to use these extensions.

Cache variables:

* PHP_HAVE_AVX512_SUPPORTS - Whether compiler supports AVX-512.
* PHP_HAVE_AVX512_VBMI_SUPPORTS - Whether compiler supports AVX-512 VBMI.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

# Skip in consecutive configuration phases.
if(DEFINED PHP_HAVE_AVX512_SUPPORTS AND DEFINED PHP_HAVE_AVX512_VBMI_SUPPORTS)
  return()
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(PHP_HAVE_AVX512_SUPPORTS FALSE)
  set(PHP_HAVE_AVX512_VBMI_SUPPORTS FALSE)
  return()
endif()

message(CHECK_START "Checking for AVX-512 extensions support")

cmake_push_check_state(RESET)
  set(
    CMAKE_REQUIRED_FLAGS
    "-mavx512f -mavx512cd -mavx512vl -mavx512dq -mavx512bw"
  )

  check_source_compiles(C [[
    #include <immintrin.h>

    int main(void)
    {
      __m512i mask = _mm512_set1_epi32(0x1);
      char out[32];
      _mm512_storeu_si512(out, _mm512_shuffle_epi8(mask, mask));

      return 0;
    }
  ]] PHP_HAVE_AVX512_SUPPORTS)
cmake_pop_check_state()

cmake_push_check_state(RESET)
  set(
    CMAKE_REQUIRED_FLAGS
    "-mavx512f -mavx512cd -mavx512vl -mavx512dq -mavx512bw -mavx512vbmi"
  )

  check_source_compiles(C [[
    #include <immintrin.h>

    int main(void)
    {
      __m512i mask = _mm512_set1_epi32(0x1);
      char out[32];
      _mm512_storeu_si512(out, _mm512_permutexvar_epi8(mask, mask));

      return 0;
    }
  ]] PHP_HAVE_AVX512_VBMI_SUPPORTS)
cmake_pop_check_state()

message(CHECK_PASS "done")
