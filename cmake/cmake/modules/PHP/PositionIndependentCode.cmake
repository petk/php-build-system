#[=============================================================================[
# PHP/PositionIndependentCode

This module wraps the
[CheckPIESupported](https://cmake.org/cmake/help/latest/module/CheckPIESupported.html)
module and sets the `CMAKE_POSITION_INDEPENDENT_CODE` variable.

With this module, the position-independent code (PIC) and position-independent
executable (PIE) compile-time and link-time options are globally enabled for all
targets. This enables building shared apache2handler, embed, and phpdbg SAPI
libraries without duplicating builds or targets for executables, static and
shared libraries.

While finer control over PIC/PIE settings may be possible, doing so
significantly increases build system complexity (two types of library and
extension objects should be built - ones with PIC enabled and those with PIC
disabled - which increases build time) or reduce usability (doing two builds
- one for executable and static SAPIs and one for shared SAPIs).

SHARED and MODULE targets always have PIC enabled by default, regardless of
this module.

## Usage

```cmake
# CMakeLists.txt
include(PHP/PositionIndependentCode)
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckPIESupported)

message(CHECK_START "Detecting linker PIE support")
check_pie_supported()
message(CHECK_PASS "done")

if(NOT DEFINED CMAKE_POSITION_INDEPENDENT_CODE)
  set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

message(
  STATUS
  "CMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE}"
)
