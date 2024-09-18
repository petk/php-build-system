#[=============================================================================[
Check whether to enable the POSITION_INDEPENDENT_CODE or not.

https://cmake.org/cmake/help/latest/variable/CMAKE_POSITION_INDEPENDENT_CODE.html
#]=============================================================================]

if(CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_SIZEOF_VOID_P EQUAL 4)
  # On 32-bit *nix (Linux and FreeBSD at least) when using Clang, the PIC is
  # required.
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
else()
  # Disable PIC for all targets. PIC is enabled for shared extensions manually.
  set(CMAKE_POSITION_INDEPENDENT_CODE OFF)
endif()

message(
  STATUS
  "CMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE}"
)
