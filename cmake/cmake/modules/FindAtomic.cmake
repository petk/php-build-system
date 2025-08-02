#[=============================================================================[
# FindAtomic

Finds the atomic instructions:

```cmake
find_package(Atomic)
```

## Imported targets

This module defines the following imported targets:

* `Atomic::Atomic` - The Atomic library, if found.

## Result variables

* `Atomic_FOUND` - Whether atomic instructions are available.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Atomic)
target_link_libraries(example PRIVATE Atomic::Atomic)
```
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(FindPackageHandleStandardArgs)

block()
  set(test [[
    #include <stdatomic.h>

    int main(void)
    {
      atomic_flag n8_flag = ATOMIC_FLAG_INIT;
      atomic_ullong n64 = ATOMIC_VAR_INIT(0);

      atomic_flag_test_and_set(&n8_flag);
      atomic_fetch_add(&n64, 1);

      return 0;
    }
  ]])

  check_source_compiles(C "${test}" _atomic_found)

  if(NOT _atomic_found)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES atomic)
      set(CMAKE_REQUIRED_QUIET TRUE)
      check_source_compiles(C "${test}" _atomic_found_in_library)
    cmake_pop_check_state()
  endif()
endblock()

if(_atomic_found OR _atomic_found_in_library)
  set(Atomic_FOUND TRUE)
endif()

if(_atomic_found_in_library)
  set(Atomic_LIBRARY atomic)
endif()

find_package_handle_standard_args(
  Atomic
  REQUIRED_VARS Atomic_FOUND
  REASON_FAILURE_MESSAGE
    "Atomic not found. Please install compiler that supports atomic."
)

if(NOT Atomic_FOUND)
  return()
endif()

if(NOT TARGET Atomic::Atomic)
  add_library(Atomic::Atomic INTERFACE IMPORTED)

  set_target_properties(
    Atomic::Atomic
    PROPERTIES
      INTERFACE_LINK_LIBRARIES "${Atomic_LIBRARY}"
  )
endif()
