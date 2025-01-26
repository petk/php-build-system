#[=============================================================================[
# PHP/PositionIndependentCode

Check whether to enable the `POSITION_INDEPENDENT_CODE` or not for all targets.
The SHARED and MODULE targets have PIC enabled regardless of this option.

TODO: This unconditionally enables position independent code globally, to be
able to build shared apache2handler, embed, and phpdbg SAPIs. Probably could be
fine tuned in the future better but it can exponentially complicate the build
system code or the build usability.

https://cmake.org/cmake/help/latest/variable/CMAKE_POSITION_INDEPENDENT_CODE.html
#]=============================================================================]

include_guard(GLOBAL)

block()
  include(CheckPIESupported)
  check_pie_supported(OUTPUT_VARIABLE output)
  if(NOT CMAKE_C_LINK_PIE_SUPPORTED)
    message(
      WARNING
      "Position independent executable (PIE) is not supported at link time: "
      "${output}.\n"
      "PIE link options will not be passed to linker."
    )
  endif()
endblock()

if(NOT DEFINED CMAKE_POSITION_INDEPENDENT_CODE)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

message(
  STATUS
  "CMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE}"
)
