#[=============================================================================[
Find DTrace.

Result variables:

  DTrace_FOUND
    Whether DTrace library is found.
  DTrace_EXECUTABLE
    Path to the DTrace command-line utility.

Cache variables:

  HAVE_DTRACE
    Whether DTrace support is enabled.

Module defines the following function:

  dtrace_target(TARGET <target-name>
                INPUT <input>
                HEADER <header>
                SOURCES <source>...
               )

    TARGET
      Target name to append the generated DTrace probe definition object file.
    INPUT
      Name of the file with DTrace probe descriptions.
    HEADER
      Name of the DTrace probe header file.
    SOURCES
      A list of project source files to build DTrace object.
#]=============================================================================]

include(CheckIncludeFile)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(DTrace PROPERTIES
  URL "https://dtrace.org/"
  DESCRIPTION "Performance analysis and troubleshooting tool"
  PURPOSE "https://sourceware.org/systemtap"
)

set(_reason_failure_message)

check_include_file(sys/sdt.h HAVE_SYS_SDT_H)

if(NOT HAVE_SYS_SDT_H)
  string(
    APPEND _reason_failure_message
    "\n    Cannot find sys/sdt.h which is required for DTrace support."
  )
endif()

find_program(
  DTrace_EXECUTABLE
  dtrace
  PATHS /usr/bin /usr/sbin
  DOC "The dtrace executable path"
)
mark_as_advanced(DTrace_EXECUTABLE)

if(NOT DTrace_EXECUTABLE)
  string(
    APPEND _reason_failure_message
    "\n    Could not find the dtrace generation tool. Please install DTrace."
  )
endif()

find_package_handle_standard_args(
  DTrace
  REQUIRED_VARS DTrace_EXECUTABLE HAVE_SYS_SDT_H
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(NOT DTrace_FOUND)
  return()
endif()

set(HAVE_DTRACE 1 CACHE INTERNAL "Whether to enable DTrace support")

function(dtrace_target)
  cmake_parse_arguments(
    parsed                # prefix
    ""                    # options
    "TARGET;INPUT;HEADER" # one-value keywords
    "SOURCES"             # multi-value keywords
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

  if(NOT parsed_INPUT)
    message(FATAL_ERROR "dtrace_target expects an input filename")
  endif()

  if(NOT parsed_HEADER)
    message(FATAL_ERROR "dtrace_target expects a header filename")
  endif()

  if(NOT parsed_SOURCES)
    message(FATAL_ERROR "dtrace_target expects a list of source files")
  endif()

  if(NOT TARGET ${parsed_TARGET})
    message(FATAL_ERROR "dtrace_target: ${parsed_TARGET} is not a target")
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
    CONTENT "
      file(READ \"\$\{DTRACE_HEADER_FILE\}\" file_contents)
      string(REPLACE \"PHP_\" \"DTRACE_\" file_contents \"\$\{file_contents\}\")
      file(WRITE \"\$\{DTRACE_HEADER_FILE\}\" \"\$\{file_contents\}\")
    "
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
    PRIVATE ${CMAKE_SOURCE_DIR}/Zend
            ${CMAKE_SOURCE_DIR}/main
            ${CMAKE_SOURCE_DIR}/TSRM
            ${CMAKE_BINARY_DIR}/Zend
            ${CMAKE_BINARY_DIR}/main
            ${CMAKE_SOURCE_DIR}
            ${CMAKE_BINARY_DIR}
            ${CMAKE_BINARY_DIR}/ext/date/lib
  )

  cmake_path(GET parsed_INPUT FILENAME input)
  set(output_filename CMakeFiles/${input}.o)

  add_custom_command(
    OUTPUT ${output_filename}
    COMMAND CC="${CMAKE_C_COMPILER}" ${DTrace_EXECUTABLE}
      -s ${parsed_INPUT} $<TARGET_OBJECTS:${parsed_TARGET}_object>
      -G # Generate a systemtap probe definition object file.
      -o ${output_filename}
    DEPENDS ${parsed_TARGET}_object
    COMMENT "[DTrace] Generating DTrace probe object ${output_filename}"
    VERBATIM
  )

  target_sources(${parsed_TARGET} PRIVATE ${output_filename})
endfunction()
