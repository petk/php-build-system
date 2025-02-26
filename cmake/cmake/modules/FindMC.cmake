#[=============================================================================[
# FindMC

Find Windows compatible message compiler (mc.exe or windmc) command-line tool.

Message compiler is installed on Windows as part of the Visual Studio or Windows
SDK. When cross-compiling for Windows, there is also a compatible alternative by
GNU (most commonly available via MinGW binutils packages) - windmc:
https://sourceware.org/binutils/docs/binutils.html#windmc.

## Result variables

* `MC_FOUND` - Whether message compiler is found.

## Cache variables

* `MC_EXECUTABLE` - Path to the message compiler if found.

## Functions provided by this module

Module exposes the following function:

```cmake
mc_target(
  NAME <name>
  INPUT <input>
  [HEADER_DIR <header-directory>]
  [RC_DIR <rc-directory>]
  [XDBG_DIR <xdbg-directory>]
  [OPTIONS <options>...]
  [DEPENDS <depends>...]
)
```

* `NAME` - Target name.
* `INPUT` - Input message file to compile.
* `HEADER_DIR` - Set the export directory for headers, otherwise current binary
  directory will be used.
* `RC_DIR` - Set the export directory for rc files.
* `XDBG_DIR` - Where to create the .dbg C include file that maps message IDs to
  their symbolic name.
* `OPTIONS` - A list of additional options to pass to message compiler tool.
* `DEPENDS` - Optional list of dependent files to recompile message file.

## Usage

```cmake
# CMakeLists.txt
find_package(MC)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  MC
  PROPERTIES
    URL "https://learn.microsoft.com/windows/win32/wes/message-compiler--mc-exe-"
    DESCRIPTION "Compiler for instrumentation manifests and message text files"
)

# Query Windows registry. Message compiler (mc.exe) is not in PATH by default.
block()
  # Windows development terminals set environment variable.
  list(APPEND hints $ENV{WindowsSdkVerBinPath})

  # Windows < 8.
  cmake_host_system_information(
    RESULT kit
    QUERY WINDOWS_REGISTRY
      "HKLM/SOFTWARE/Microsoft/Windows Kits/Installed Roots"
    VALUE KitsRoot
  )
  list(APPEND hints ${kit}/bin)

  # Windows 8.1.
  cmake_host_system_information(
    RESULT kit81
    QUERY WINDOWS_REGISTRY
      "HKLM/SOFTWARE/Microsoft/Windows Kits/Installed Roots"
    VALUE KitsRoot81
  )
  list(APPEND hints ${kit81}/bin)

  # Visual studio 2019-2022.
  cmake_host_system_information(
    RESULT kit10
    QUERY WINDOWS_REGISTRY
      "HKLM/SOFTWARE/Microsoft/Windows Kits/Installed Roots"
    VALUE KitsRoot10
  )
  cmake_host_system_information(
    RESULT kit10wow
    QUERY WINDOWS_REGISTRY
      "HKLM/SOFTWARE/WOW6432Node/Microsoft/Windows Kits/Installed Roots"
    VALUE KitsRoot10
  )
  file(GLOB kit10_list ${kit10}/bin/1[0-9].* ${kit10wow}/bin/1[0-9].*)
  foreach(item ${kit10_list})
    if(IS_DIRECTORY ${item})
      list(APPEND hints ${item})
    endif()
  endforeach()

  # Adjustments for architecture whether target is 64-bit or 32-bit.
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    if(CMAKE_SYSTEM_PROCESSOR STREQUAL "ARM64")
      list(TRANSFORM hints APPEND /arm64)
    else()
      list(TRANSFORM hints APPEND /x64)
    endif()

    # GNU windmc.
    list(APPEND names "x86_64-w64-mingw32-windmc")
  else()
    list(TRANSFORM hints APPEND /x86)

    # GNU windmc.
    list(APPEND names "i686-w64-mingw32-windmc")
  endif()

  find_program(
    MC_EXECUTABLE
    NAMES
      # Windows
      mc.exe
      # GNU binutils (part of MinGW)
      windmc
      # When cross-compiling for Windows target, binutils package might not
      # provide link to windmc executable but might have names like this:
      ${names}
    HINTS ${hints}
    DOC "Path to the message compiler (mc)"
  )
endblock()

set(_reason "")

if(NOT MC_EXECUTABLE OR NOT EXISTS ${MC_EXECUTABLE})
  string(APPEND _reason "Message compiler command-line tool (mc) not found. ")
else()
  # If MC_EXECUTABLE was found or was set by the user and path exists.
  set(_mc_exists TRUE)
endif()

mark_as_advanced(MC_EXECUTABLE)

find_package_handle_standard_args(
  MC
  REQUIRED_VARS
    MC_EXECUTABLE
    _mc_exists
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
unset(_mc_exists)

function(mc_target)
  cmake_parse_arguments(
    parsed                                  # prefix
    ""                                      # options
    "NAME;INPUT;HEADER_DIR;RC_DIR;XDBG_DIR" # one-value keywords
    "DEPENDS"                               # multi-value keywords
    ${ARGN}                                 # strings to parse
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT parsed_NAME)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} expects a target name.")
  endif()

  if(NOT parsed_INPUT)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} expects an input filename.")
  endif()

  if(NOT MC_FOUND)
    message(
      WARNING
      "[MC][${parsed_NAME}] Message compiler is missing. Skipping."
    )
    return()
  endif()

  # Set default header export directory if empty.
  if(NOT parsed_HEADER_DIR)
    set(parsed_HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()

  # Set default rc export directory.
  if(NOT parsed_RC_DIR)
    set(parsed_RC_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()

  # Set filename stem.
  cmake_path(GET parsed_INPUT STEM output LAST_ONLY)
  set(output "${parsed_HEADER_DIR}/${output}.h")

  # Path where to create the .dbg C include file.
  if(parsed_XDBG_DIR)
    list(APPEND options -x "${parsed_XDBG_DIR}")
  endif()

  add_custom_command(
    OUTPUT "${output}"
    COMMAND ${MC_EXECUTABLE}
      # Header export directory:
      -h "${parsed_HEADER_DIR}"
      # Export directory for rc files:
      -r "${parsed_RC_DIR}"
      # Rest of the options:
      ${options}
      # Message file input:
      "${parsed_INPUT}"
    DEPENDS ${parsed_INPUT} ${parsed_DEPENDS}
    VERBATIM
  )

  cmake_path(
    RELATIVE_PATH
    output
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE relativePath
  )

  add_custom_target(
    ${parsed_NAME}
    SOURCES "${parsed_INPUT}"
    DEPENDS "${output}"
    COMMENT "[MC][${parsed_NAME}] Generating ${relativePath}"
  )
endfunction()
