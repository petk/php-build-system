#[=============================================================================[
# FindBISON

Find `bison`, the general-purpose parser generator, command-line executable.

This module extends the upstream CMake `FindBISON` module.
See: https://cmake.org/cmake/help/latest/module/FindBISON.html
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

################################################################################
# Configuration.
################################################################################

set_package_properties(
  BISON
  PROPERTIES
    URL "https://www.gnu.org/software/bison/"
    DESCRIPTION "General-purpose parser generator"
)

# Find package with upstream CMake module; override CMAKE_MODULE_PATH to prevent
# the maximum nesting/recursion depth error on some systems, like macOS.
#set(_php_cmake_module_path ${CMAKE_MODULE_PATH})
#unset(CMAKE_MODULE_PATH)
#include(FindBISON)
#set(CMAKE_MODULE_PATH ${_php_cmake_module_path})
#unset(_php_cmake_module_path)

################################################################################
# Find the executable.
################################################################################

set(_reason "")

find_program(
  BISON_EXECUTABLE
  NAMES bison win-bison win_bison
  DOC "The path to the bison executable"
)
mark_as_advanced(BISON_EXECUTABLE)

if(NOT BISON_EXECUTABLE)
  string(APPEND _reason "The bison command-line executable not found. ")
endif()

################################################################################
# Check version.
################################################################################

block(PROPAGATE BISON_VERSION _reason)
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
    set(test IS_EXECUTABLE)
  else()
    set(test EXISTS)
  endif()

  if(${test} ${BISON_EXECUTABLE})
    execute_process(
      COMMAND ${BISON_EXECUTABLE} --version
      OUTPUT_VARIABLE version
      RESULT_VARIABLE result
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT result EQUAL 0)
      string(APPEND _reason "Command ${BISON_EXECUTABLE} --version failed. ")
    elseif(version)
      # Bison++
      if(version MATCHES "^bison\\+\\+ Version ([^,]+)")
        set(BISON_VERSION "${CMAKE_MATCH_1}")
      # GNU Bison
      elseif(version MATCHES "^bison \\(GNU Bison\\) ([^\n]+)\n")
        set(BISON_VERSION "${CMAKE_MATCH_1}")
      elseif(version MATCHES "^GNU Bison (version )?([^\n]+)")
        set(BISON_VERSION "${CMAKE_MATCH_2}")
      else()
        string(APPEND _reason "Invalid version format. ")
      endif()
    endif()
  endif()
endblock()

find_package_handle_standard_args(
  BISON
  REQUIRED_VARS BISON_EXECUTABLE BISON_VERSION
  VERSION_VAR BISON_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
