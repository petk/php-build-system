#[=============================================================================[
# FindDTrace

Finds DTrace and provides command for using it in CMake:

```cmake
find_package(DTrace [...])
```

DTrace (Dynamic Tracing), a comprehensive tracing framework originally developed
by Sun Microsystems for troubleshooting and performance analysis on Unix-like
systems. While the name "DTrace" is associated with the original implementation
(now maintained by the DTrace.org community), there are other compatible
implementations such as SystemTap, which is widely used on Linux systems.

This module specifically detects and uses the SystemTap implementation of
DTrace.

## Imported targets

This module provides the following imported targets:

* `DTrace::DTrace` - The package library, if found.

## Result variables

This module defines the following variables:

* `DTrace_FOUND` - Boolean indicating whether DTrace support was found.

## Cache variables

The following cache variables may also be set:

* `DTrace_INCLUDE_DIR` - Directory containing DTrace library headers.
* `DTrace_EXECUTABLE` - Path to the DTrace command-line utility.

## Commands

This module provides the following commands if DTrace was found:

### `dtrace_target()`

Initializes the DTrace support:

```cmake
dtrace_target(
  <target-name>
  INPUT <input>
  HEADER <header>
  SOURCES <sources>...
  [LINK_LIBRARIES <libs>...]
)
```

This command generates DTrace header `<header>` and creates `INTERFACE` library
`<target-name>` with probe definition object file added as an INTERFACE source.

The arguments are:

* `<target-name>` - DTrace INTERFACE library with the generated DTrace probe
  definition object file.
* `INPUT <input>` - Name of the file with DTrace probe descriptions. Relative
  path is interpreted as being relative to the current source directory.
* `HEADER <header>` - Name of the DTrace probe header file to be generated.
  Relative path is interpreted as being relative to the current binary
  directory.
* `SOURCES <sources>...` - A list of source files to build DTrace object.
  Relative paths are interpreted as being relative to the current source
  directory.
* `LINK_LIBRARIES <libs>...` - Optional. A list of system libraries or CMake
  targets to be linked in the generated DTrace object target.

## Examples

Basic usage:

```cmake
# CMakeLists.txt

find_package(DTrace)

if(DTrace_FOUND)
  dtrace_target(
    foo_dtrace
    INPUT foo_dtrace.d
    HEADER foo_dtrace_generated.h
    SOURCES foo.c ...
  )

  target_link_libraries(foo PRIVATE DTrace::DTrace)
endif()

add_executable(bar)
target_link_libraries(bar PRIVATE foo_dtrace)
```
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  DTrace
  PROPERTIES
    URL "https://sourceware.org/systemtap"
    DESCRIPTION "Performance analysis and troubleshooting tool"
)

block(PROPAGATE DTrace_FOUND)
  set(reason "")

  find_path(
    DTrace_INCLUDE_DIR
    NAMES sys/sdt.h
    DOC "Directory containing DTrace library headers"
  )
  mark_as_advanced(DTrace_INCLUDE_DIR)

  if(NOT DTrace_INCLUDE_DIR)
    string(APPEND reason "<sys/sdt.h> not found. ")
  endif()

  find_program(
    DTrace_EXECUTABLE
    NAMES dtrace
    DOC "The path to the executable dtrace generation tool"
  )
  mark_as_advanced(DTrace_EXECUTABLE)

  if(NOT DTrace_EXECUTABLE)
    string(
      APPEND reason
      "DTrace command-line generation tool not found. Please install DTrace. "
    )
  endif()

  find_package_handle_standard_args(
    DTrace
    REQUIRED_VARS DTrace_EXECUTABLE DTrace_INCLUDE_DIR
    REASON_FAILURE_MESSAGE "${reason}"
  )
endblock()

if(NOT DTrace_FOUND)
  return()
endif()

if(NOT TARGET DTrace::DTrace)
  add_library(DTrace::DTrace INTERFACE IMPORTED)
  set_target_properties(
    DTrace::DTrace
    PROPERTIES INTERFACE_INCLUDE_DIRECTORIES ${DTrace_INCLUDE_DIR}
  )
endif()

function(dtrace_target)
  cmake_parse_arguments(
    PARSE_ARGV 1
    parsed
    ""
    "INPUT;HEADER"
    "SOURCES;LINK_LIBRARIES"
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT ARGV0)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} expects a target name.")
  endif()

  if(NOT parsed_INPUT)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} expects an input filename.")
  endif()

  if(NOT parsed_HEADER)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} expects a header filename.")
  endif()

  if(NOT parsed_SOURCES)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} expects source files.")
  endif()

  cmake_path(
    ABSOLUTE_PATH parsed_INPUT
    BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    NORMALIZE
  )

  cmake_path(
    ABSOLUTE_PATH parsed_HEADER
    BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    NORMALIZE
  )

  set(sources "")
  foreach(source IN LISTS parsed_SOURCES)
    cmake_path(
      ABSOLUTE_PATH source
      BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      NORMALIZE
    )
    list(APPEND sources ${source})
  endforeach()
  set(parsed_SOURCES ${sources})

  # Generate DTrace header.
  file(
    CONFIGURE
    OUTPUT CMakeFiles/GenerateDTraceHeader.cmake
    CONTENT
      [[
        execute_process(
          COMMAND
            "@DTrace_EXECUTABLE@"
            -s "@parsed_INPUT@"  # Input file.
            -h                   # Generate a SystemTap header file.
            -C                   # Run the C preprocessor (cpp) on the input file.
            -o "@parsed_HEADER@" # Output file.
        )
        # Patch DTrace header.
        file(READ "@parsed_HEADER@" content)
        string(REPLACE "PHP_" "DTRACE_" content "${content}")
        file(WRITE "@parsed_HEADER@" "${content}")
      ]]
    @ONLY
  )
  cmake_path(
    RELATIVE_PATH parsed_HEADER
    BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    OUTPUT_VARIABLE header
  )
  add_custom_command(
    OUTPUT ${parsed_HEADER}
    COMMAND ${CMAKE_COMMAND} -P CMakeFiles/GenerateDTraceHeader.cmake
    DEPENDS "${parsed_INPUT}"
    COMMENT "[DTrace] Generating ${header}"
    VERBATIM
    COMMAND_EXPAND_LISTS
  )

  # Generate DTrace object.
  set(target ${ARGV0})
  add_library(${target}_object OBJECT ${parsed_SOURCES} ${parsed_HEADER})
  target_link_libraries(${target}_object PRIVATE DTrace::DTrace)

  if(parsed_LINK_LIBRARIES)
    target_link_libraries(${target}_object PRIVATE ${parsed_LINK_LIBRARIES})
  endif()

  cmake_path(GET parsed_INPUT FILENAME input)
  set(output CMakeFiles/${input}.o)
  cmake_path(GET CMAKE_CURRENT_BINARY_DIR FILENAME parent)

  add_custom_command(
    OUTPUT ${output}
    # gersemi: off
    COMMAND
      CC="${CMAKE_C_COMPILER}"
      ${DTrace_EXECUTABLE}
      -s ${parsed_INPUT} $<TARGET_OBJECTS:${target}_object>
      -G # Generate a SystemTap probe definition object file.
      -o ${output}
      -I${DTrace_INCLUDE_DIR}
    # gersemi: on
    DEPENDS ${target}_object
    COMMENT "[DTrace] Generating DTrace probe object ${parent}/${output}"
    VERBATIM
    COMMAND_EXPAND_LISTS
  )
  add_custom_target(${target}_generator DEPENDS ${output})

  add_library(${target} INTERFACE)
  target_sources(${target} INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/${output})
  add_dependencies(${target} ${target}_generator)
endfunction()
