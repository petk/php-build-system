#[=============================================================================[
Find DTrace.

Result variables:

  DTrace_FOUND
    Whether DTrace library is found.

Cache variables:

  DTrace_INCLUDE_DIR
    Directory containing DTrace library headers.
  DTrace_EXECUTABLE
    Path to the DTrace command-line utility.
  HAVE_DTRACE
    Whether DTrace support is enabled.

Hints:

  The DTrace_ROOT variable adds custom search path.

Module defines the following function:

  dtrace_target(
    TARGET <target-name>
    INPUT <input>
    HEADER <header>
    SOURCES <source>...
    [INCLUDES <includes>...]
  )

    TARGET
      Target name to append the generated DTrace probe definition object file.
    INPUT
      Name of the file with DTrace probe descriptions.
    HEADER
      Name of the DTrace probe header file.
    SOURCES
      A list of project source files to build DTrace object.
    INCLUDES
      A list of include directories for appending to DTrace object.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  DTrace
  PROPERTIES
    URL "https://dtrace.org/"
    DESCRIPTION "Performance analysis and troubleshooting tool"
    PURPOSE "https://sourceware.org/systemtap"
)

set(_reason "")

find_path(
  DTrace_INCLUDE_DIR
  NAMES sys/sdt.h
  DOC "Directory containing DTrace library headers"
)

find_program(
  DTrace_EXECUTABLE
  NAMES dtrace
  DOC "The path to the executable dtrace generation tool"
)

if(NOT DTrace_EXECUTABLE)
  string(APPEND _reason "DTrace generation tool not found. Please install DTrace. ")
endif()

if(NOT DTrace_INCLUDE_DIR)
  string(APPEND _reason "sys/sdt.h not found. ")
endif()

mark_as_advanced(DTrace_EXECUTABLE)

find_package_handle_standard_args(
  DTrace
  REQUIRED_VARS
    DTrace_EXECUTABLE
    DTrace_INCLUDE_DIR
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT DTrace_FOUND)
  return()
endif()

set(HAVE_DTRACE 1 CACHE INTERNAL "Whether to enable DTrace support")

function(dtrace_target)
  cmake_parse_arguments(
    parsed                # prefix
    ""                    # options
    "TARGET;INPUT;HEADER" # one-value keywords
    "SOURCES;INCLUDES"    # multi-value keywords
    ${ARGN}               # strings to parse
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  if(NOT parsed_TARGET)
    message(FATAL_ERROR "dtrace_target expects a target name")
  endif()

  if(NOT TARGET ${parsed_TARGET})
    message(FATAL_ERROR "dtrace_target: ${parsed_TARGET} is not a target")
  endif()

  if(NOT parsed_INPUT)
    message(FATAL_ERROR "dtrace_target expects an input filename")
  endif()

  if(NOT parsed_HEADER)
    message(FATAL_ERROR "dtrace_target expects a header filename")
  endif()

  if(NOT parsed_SOURCES)
    message(FATAL_ERROR "dtrace_target expects a list of source files")
  endif()

  # Generate DTrace header.
  add_custom_command(
    OUTPUT "${parsed_HEADER}"
    COMMAND ${DTrace_EXECUTABLE}
      -s "${parsed_INPUT}"
      -h                    # Generate a systemtap header file.
      -C                    # Run the cpp preprocessor on the input file.
      -o "${parsed_HEADER}" # Name of the output file.
    DEPENDS "${parsed_INPUT}"
    COMMENT "[DTrace] Generating DTrace ${parsed_HEADER}"
    VERBATIM
  )

  # Patch DTrace header.
  file(
    GENERATE
    OUTPUT CMakeFiles/PatchDTraceHeader.cmake
    CONTENT [[
      file(READ "${DTRACE_HEADER_FILE}" content)
      string(REPLACE "PHP_" "DTRACE_" content "${content}")
      file(WRITE "${DTRACE_HEADER_FILE}" "${content}")
    ]]
  )
  add_custom_target(
    ${parsed_TARGET}_patch_header
    COMMAND ${CMAKE_COMMAND}
      -DDTRACE_HEADER_FILE=${parsed_HEADER}
      -P CMakeFiles/PatchDTraceHeader.cmake
    DEPENDS ${parsed_HEADER}
    COMMENT "[DTrace] Patching ${parsed_HEADER}"
  )

  add_library(${parsed_TARGET}_object OBJECT ${parsed_SOURCES})

  add_dependencies(${parsed_TARGET}_object ${parsed_TARGET}_patch_header)

  target_include_directories(
    ${parsed_TARGET}_object
    PRIVATE
      ${DTrace_INCLUDE_DIR}
      ${parsed_INCLUDES}
  )

  cmake_path(GET parsed_INPUT FILENAME input)
  set(output_filename CMakeFiles/${input}.o)

  add_custom_command(
    OUTPUT ${output_filename}
    COMMAND CC="${CMAKE_C_COMPILER}" ${DTrace_EXECUTABLE}
      -s ${parsed_INPUT} $<TARGET_OBJECTS:${parsed_TARGET}_object>
      -G # Generate a systemtap probe definition object file.
      -o ${output_filename}
      -I${DTrace_INCLUDE_DIR}
    DEPENDS ${parsed_TARGET}_object
    COMMENT "[DTrace] Generating DTrace probe object ${output_filename}"
    VERBATIM
  )

  target_sources(${parsed_TARGET} PRIVATE ${output_filename})
  target_include_directories(${parsed_TARGET} PUBLIC ${DTrace_INCLUDE_DIR})
endfunction()
