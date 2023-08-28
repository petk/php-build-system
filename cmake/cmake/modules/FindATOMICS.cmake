#[=============================================================================[
CMake module to find and use the Atomics library.

ATOMICS_FOUND
  Set to 1 if atomics library is available
ATOMICS_LIBRARIES
  A list of atomics libraries needed in order to use Atomics functionality.
#]=============================================================================]

include(CheckCSourceCompiles)
include(CMakePushCheckState)
include(FindPackageHandleStandardArgs)

set(_atomic_test "
  #include <stdatomic.h>

  int main(void) {
    atomic_flag n8_flag = ATOMIC_FLAG_INIT;
    atomic_ullong n64 = ATOMIC_VAR_INIT(0);

    atomic_flag_test_and_set(&n8_flag);
    atomic_fetch_add(&n64, 1);

    return 0;
  }
")

set(ATOMICS_LIBRARIES "" CACHE INTERNAL "A list of libraries needed to use Atomics")

check_c_source_compiles("${_atomic_test}" _have_atomics)

if(NOT _have_atomics)
  cmake_push_check_state()
    set(CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES} atomics")
    check_c_source_compiles("${_atomic_test}" _have_atomics_in_library)
  cmake_pop_check_state()
endif()

if(_have_atomics OR _have_atomics_in_library)
  set(ATOMICS_FOUND 1 CACHE INTERNAL "Whether the Atomics functionality is available")
endif()

if(_have_atomics_in_library)
  list(APPEND ATOMICS_LIBRARIES atomics)
endif()

unset(_have_atomics CACHE)
unset(_have_atomics_in_library CACHE)

mark_as_advanced(ATOMICS_FOUND ATOMICS_LIBRARIES)

find_package_handle_standard_args(
  ATOMICS
  REQUIRED_VARS ATOMICS_FOUND
  REASON_FAILURE_MESSAGE "ATOMICS not found. Please install compiler that supports atomics."
)
