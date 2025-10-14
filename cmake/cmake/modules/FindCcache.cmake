#[=============================================================================[
# FindCcache

Finds the Ccache compiler cache tool for faster compilation times:

```cmake
find_package(Ccache [<version>] [...])
```

## Result variables

This module defines the following variables:

* `Ccache_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `Ccache_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `Ccache_EXECUTABLE` - The path to the ccache executable.

## Hints

* The `CCACHE_DISABLE` regular or environment variable which disables ccache and
  doesn't adjust the C and CXX launcher. For more info see Ccache documentation.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Ccache)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Ccache
  PROPERTIES
    URL "https://ccache.dev"
    DESCRIPTION "Compiler cache"
    PURPOSE "Caches previous compilations and speeds up compilations."
)

set(_reason "")

find_program(
  Ccache_EXECUTABLE
  NAMES ccache
  DOC "The path to the ccache executable"
)
mark_as_advanced(Ccache_EXECUTABLE)

# Get version.
block(PROPAGATE Ccache_VERSION)
  if(Ccache_EXECUTABLE)
    execute_process(
      COMMAND ${Ccache_EXECUTABLE} --version
      OUTPUT_VARIABLE version
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(version MATCHES "^ccache version ([^\n]+)")
      set(Ccache_VERSION "${CMAKE_MATCH_1}")
    endif()
  endif()
endblock()

find_package_handle_standard_args(
  Ccache
  REQUIRED_VARS
    Ccache_EXECUTABLE
  VERSION_VAR Ccache_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Ccache_FOUND)
  message(STATUS "Ccache disabled")
  return()
endif()

if(CCACHE_DISABLE OR DEFINED ENV{CCACHE_DISABLE})
  message(STATUS "Ccache disabled ('CCACHE_DISABLE' is set)")
  return()
endif()

if(CMAKE_C_COMPILER_LOADED)
  set(CMAKE_C_COMPILER_LAUNCHER ${Ccache_EXECUTABLE})
endif()

if(CMAKE_CXX_COMPILER_LOADED)
  set(CMAKE_CXX_COMPILER_LAUNCHER ${Ccache_EXECUTABLE})
endif()
