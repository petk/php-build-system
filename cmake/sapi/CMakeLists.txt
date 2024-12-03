#[=============================================================================[
Add subdirectories of PHP SAPIs.

## Custom CMake properties

* `PHP_ALL_SAPIS`

  Global property with a list of all PHP SAPIs in the sapi directory.

* `PHP_SAPIS`

  Global property with a list of all enabled PHP SAPIs.

* `PHP_SAPI_CLI`

  Target property that designates PHP SAPI as CLI-based. These SAPIs can utilize
  CLI-based PHP extensions (for example, pcntl) and include
  main/internal_functions_cli.c object instead of the main/internal_functions.c.
#]=============================================================================]

message(STATUS "")
message(STATUS "")
message(STATUS "Configuring PHP SAPI modules")
message(STATUS "============================")
message(STATUS "")

define_property(
  GLOBAL
  PROPERTY PHP_ALL_SAPIS
  BRIEF_DOCS "A list of all PHP SAPIs in the sapi directory"
)

define_property(
  GLOBAL
  PROPERTY PHP_SAPIS
  BRIEF_DOCS "A list of all enabled PHP SAPIs"
)

define_property(
  TARGET
  PROPERTY PHP_SAPI_CLI
  BRIEF_DOCS "Whether the PHP SAPI is CLI-based to run in a CLI environment"
)

list(APPEND CMAKE_MESSAGE_CONTEXT "sapi")

# Traverse CMakeLists.txt files of PHP SAPIs.
file(GLOB sapis ${CMAKE_CURRENT_SOURCE_DIR}/*/CMakeLists.txt)
list(TRANSFORM sapis REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/|/CMakeLists.txt" "")
set_property(GLOBAL PROPERTY PHP_ALL_SAPIS ${sapis})

# Add subdirectories of SAPIs.
foreach(sapi IN LISTS sapis)
  list(APPEND CMAKE_MESSAGE_CONTEXT "${sapi}")
  message(CHECK_START "Configuring SAPI ${sapi}")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")

  add_subdirectory("${sapi}")

  list(POP_BACK CMAKE_MESSAGE_INDENT)
  if(TARGET php_${sapi})
    set_property(GLOBAL APPEND PROPERTY PHP_SAPIS ${sapi})
    message(CHECK_PASS "enabled")
  else()
    message(CHECK_FAIL "disabled")
  endif()
  list(POP_BACK CMAKE_MESSAGE_CONTEXT)
endforeach()

# Check if at least one SAPI is enabled.
get_property(sapis GLOBAL PROPERTY PHP_SAPIS)
if(NOT sapis)
  message(
    WARNING
    "None of the PHP SAPIs have been enabled. If this is intentional, you "
    "can disregard this warning."
  )
endif()
