#[=============================================================================[
CMake module to find and use the atomic instructions.

ATOMIC_FOUND
  Set to 1 if atomic instructions are available.
ATOMIC_LIBRARIES
  A list of libraries needed in order to use atomic functionality.
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

set(ATOMIC_LIBRARIES "" CACHE INTERNAL "A list of libraries needed to use atomic")

check_c_source_compiles("${_atomic_test}" _have_atomic)

if(NOT _have_atomic)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES atomic)
    check_c_source_compiles("${_atomic_test}" _have_atomic_in_library)
  cmake_pop_check_state()
endif()

if(_have_atomic OR _have_atomic_in_library)
  set(ATOMIC_FOUND 1 CACHE INTERNAL "Whether the atomic instructions are available")
endif()

if(_have_atomic_in_library)
  list(APPEND ATOMIC_LIBRARIES atomic)
endif()

unset(_have_atomic CACHE)
unset(_have_atomic_in_library CACHE)

mark_as_advanced(ATOMIC_FOUND ATOMIC_LIBRARIES)

find_package_handle_standard_args(
  ATOMIC
  REQUIRED_VARS ATOMIC_FOUND
  REASON_FAILURE_MESSAGE "ATOMIC not found. Please install compiler that supports atomic."
)
