#[=============================================================================[
Find the Ccache compiler cache tool for faster compilation times.

## Result variables

* `Ccache_FOUND` - Whether the package has been found.
* `Ccache_VERSION` - Package version, if found.

## Cache variables

* `Ccache_EXECUTABLE` - The path to the ccache executable.

## Hints

* The `CCACHE_DISABLE` environment variable disables the ccache and doesn't add
  it to the C and CXX launcher, see Ccache documentation for more info.
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

    string(REGEX MATCH "^ccache version ([^\r\n]+)" _ "${version}")

    if(CMAKE_MATCH_1)
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

if(NOT Ccache_FOUND OR CCACHE_DISABLE OR "$ENV{CCACHE_DISABLE}")
  message(STATUS "Ccache disabled")
  return()
endif()

if(CMAKE_C_COMPILER_LOADED)
  set(CMAKE_C_COMPILER_LAUNCHER ${Ccache_EXECUTABLE})
endif()

if(CMAKE_CXX_COMPILER_LOADED)
  set(CMAKE_CXX_COMPILER_LAUNCHER ${Ccache_EXECUTABLE})
endif()
