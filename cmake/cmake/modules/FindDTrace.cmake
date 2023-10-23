#[=============================================================================[
Find DTrace.
http://dtrace.org/blogs/about/
https://sourceware.org/systemtap

Result variables:

  DTrace_FOUND
    Set to 1 if DTrace library is found.
  DTrace_EXECUTABLE
    Path to the DTrace command-line utility.

Cache variables:

  HAVE_DTRACE
    Set to 1 if DTrace support is enabled.

Module defines the following function:

  dtrace_target(TARGET <target-name>
                INPUT <input>
                HEADER <header>
                SOURCES <source>...
               )

  TARGET
    Name of the target to append the generated DTrace probe definition object file.
  INPUT
    Name of the file with DTrace probe descriptions.
  HEADER
    Name of the DTrace probe header file.
  SOURCES
    A list of project source files to build DTrace object.
#]=============================================================================]

include(CheckIncludeFile)
include(FindPackageHandleStandardArgs)

check_include_file(sys/sdt.h HAVE_SYS_SDT_H)

if(NOT HAVE_SYS_SDT_H)
  message(WARNING "Cannot find sys/sdt.h which is required for DTrace support")
endif()

find_program(
  DTrace_EXECUTABLE
  dtrace
  PATHS /usr/bin /usr/sbin
  DOC "The dtrace executable path"
)
mark_as_advanced(DTrace_EXECUTABLE)

if(NOT DTrace_EXECUTABLE)
  message(WARNING "Could not find the dtrace generation tool. Please install DTrace.")
endif()

find_package_handle_standard_args(
  DTrace
  REQUIRED_VARS DTrace_EXECUTABLE HAVE_SYS_SDT_H
)

if(DTrace_FOUND)
  set(HAVE_DTRACE 1 CACHE INTERNAL "Whether to enable DTrace support")

  function(dtrace_target)
    set(one_value_args TARGET INPUT HEADER)
    set(multi_value_args SOURCES)

    cmake_parse_arguments(
      PARSED_ARGS
      ""
      "${one_value_args}"
      "${multi_value_args}"
      ${ARGN}
    )

    if(NOT PARSED_ARGS_TARGET)
      message(FATAL_ERROR "dtrace_target expects a target name")
    endif()

    if(NOT PARSED_ARGS_INPUT)
      message(FATAL_ERROR "dtrace_target expects an input filename")
    endif()

    if(NOT PARSED_ARGS_HEADER)
      message(FATAL_ERROR "dtrace_target expects a header filename")
    endif()

    if(NOT PARSED_ARGS_SOURCES)
      message(FATAL_ERROR "dtrace_target expects a list of source files")
    endif()

    # Generate DTrace header.
    add_custom_command(
      OUTPUT "${PARSED_ARGS_HEADER}"
      COMMAND ${DTrace_EXECUTABLE}
        -s "${PARSED_ARGS_INPUT}"
        -h -C
        -o "${PARSED_ARGS_HEADER}"
      DEPENDS "${PARSED_ARGS_INPUT}"
      COMMENT "[DTrace] Generating DTrace ${PARSED_ARGS_HEADER}"
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
      ${PARSED_ARGS_TARGET}_patch_header
      COMMAND ${CMAKE_COMMAND}
        -DDTRACE_HEADER_FILE=${PARSED_ARGS_HEADER}
        -P CMakeFiles/PatchDTraceHeader.cmake
      DEPENDS ${PARSED_ARGS_HEADER}
      COMMENT "[DTrace] Patching ${PARSED_ARGS_HEADER}"
    )

    add_library(${PARSED_ARGS_TARGET}_object OBJECT ${PARSED_ARGS_SOURCES})

    add_dependencies(${PARSED_ARGS_TARGET}_object ${PARSED_ARGS_TARGET}_patch_header)

    target_include_directories(
      ${PARSED_ARGS_TARGET}_object
      PRIVATE ${CMAKE_SOURCE_DIR}/Zend
              ${CMAKE_SOURCE_DIR}/main
              ${CMAKE_SOURCE_DIR}/TSRM
              ${CMAKE_BINARY_DIR}/Zend
              ${CMAKE_BINARY_DIR}/main
              ${CMAKE_SOURCE_DIR}
              ${CMAKE_BINARY_DIR}
              ${CMAKE_BINARY_DIR}/ext/date/lib
    )

    cmake_path(GET PARSED_ARGS_INPUT FILENAME input)
    set(output_filename CMakeFiles/${input}.o)

    add_custom_command(
      OUTPUT ${output_filename}
      COMMAND CC="${CMAKE_C_COMPILER}" ${DTrace_EXECUTABLE}
        -s ${PARSED_ARGS_INPUT} $<TARGET_OBJECTS:${PARSED_ARGS_TARGET}_object>
        -G
        -o ${output_filename}
      DEPENDS ${PARSED_ARGS_TARGET}_object
      COMMENT "[DTrace] Generating DTrace probe object ${output_filename}"
      VERBATIM
    )

    target_sources(${PARSED_ARGS_TARGET} PRIVATE ${output_filename})
  endfunction()
endif()
