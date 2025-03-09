#[=============================================================================[
# PHP/PositionIndependentCode

Wrapper module for CMake's `CheckPIESupported` module and
`CMAKE_POSITION_INDEPENDENT_CODE` variable.

This module checks whether to enable the `POSITION_INDEPENDENT_CODE` target
property for all targets globally. The SHARED and MODULE targets have PIC always
enabled by default regardless of this module.

Position independent code (PIC) and position independent executable (PIE)
compile-time and link-time options are for now unconditionally added globally to
all targets, to be able to build shared apache2handler, embed, and phpdbg SAPI
libraries. This probably could be fine tuned in the future further but it can
exponentially complicate the build system code or the build usability.

## Usage

```cmake
# CMakeLists.txt
include(PHP/PositionIndependentCode)
```
#]=============================================================================]

include_guard(GLOBAL)

block()
  include(CheckPIESupported)

  message(CHECK_START "Checking if linker supports PIE")

  check_pie_supported(OUTPUT_VARIABLE output)

  if(CMAKE_C_LINK_PIE_SUPPORTED)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")

    if(
      CMAKE_VERSION VERSION_GREATER_EQUAL 3.26
      AND NOT DEFINED _PHP_POSITION_INDEPENDENT_CODE_LOGGED
    )
      message(
        CONFIGURE_LOG
        "Position independent executable (PIE) is not supported at link time:\n"
        "${output}"
        "PIE link options will not be passed to linker."
      )

      set(
        _PHP_POSITION_INDEPENDENT_CODE_LOGGED
        TRUE
        CACHE INTERNAL
        "Internal marker whether PIE check has been logged."
      )
    endif()
  endif()
endblock()

if(NOT DEFINED CMAKE_POSITION_INDEPENDENT_CODE)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

message(
  STATUS
  "CMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE}"
)
