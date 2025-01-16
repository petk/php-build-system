#[=============================================================================[
# PHP/PositionIndependentCode

Check whether to enable the `POSITION_INDEPENDENT_CODE` or not for all targets.
The SHARED and MODULE targets have PIC enabled regardless of this option.

https://cmake.org/cmake/help/latest/variable/CMAKE_POSITION_INDEPENDENT_CODE.html
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_SIZEOF_VOID_P EQUAL 4)
  # On 32-bit *nix (Linux and FreeBSD at least) when using Clang, the PIC is
  # required.
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
else()
  set(CMAKE_POSITION_INDEPENDENT_CODE OFF)
endif()

message(
  STATUS
  "CMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE}"
)
