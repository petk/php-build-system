#[=============================================================================[
Add subdirectories of PHP SAPIs.

## Custom CMake properties

* `PHP_ALL_SAPIS`

  Global property with a list of all PHP SAPIs in the sapi directory.

* `PHP_SAPIS`

  Global property with a list of all enabled PHP SAPIs.
#]=============================================================================]

message(
  STATUS
  "----------------------------
   Configuring PHP SAPI modules
   ----------------------------"
)

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

list(APPEND CMAKE_MESSAGE_CONTEXT "sapi")

# Traverse CMakeLists.txt files of PHP SAPIs.
file(GLOB sapis ${CMAKE_CURRENT_SOURCE_DIR}/*/CMakeLists.txt)
list(TRANSFORM sapis REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/|/CMakeLists.txt" "")
set_property(GLOBAL PROPERTY PHP_ALL_SAPIS ${sapis})

foreach(sapi IN LISTS sapis)
  list(APPEND CMAKE_MESSAGE_CONTEXT "${sapi}")
  add_subdirectory("${sapi}")
  list(POP_BACK CMAKE_MESSAGE_CONTEXT)

  if(TARGET php_${sapi})
    set_property(GLOBAL APPEND PROPERTY PHP_SAPIS ${sapi})
  endif()
endforeach()

# Check if at least one SAPI is enabled.
get_cmake_property(sapis PHP_SAPIS)
if(NOT sapis)
  message(
    WARNING
    "None of the PHP SAPIs have been enabled. If this is intentional, you "
    "can disregard this warning."
  )
endif()
