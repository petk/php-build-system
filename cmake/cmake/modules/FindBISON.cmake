#[=============================================================================[
Find Bison.

See: https://cmake.org/cmake/help/latest/module/FindBISON.html

Module overrides the upstream CMake FindBISON module with few customizations:

Hints:

  The BISON_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)

set_package_properties(
  BISON
  PROPERTIES
    URL "https://www.gnu.org/software/bison/"
    DESCRIPTION "General-purpose parser generator"
)

# Find package with upstream CMake module; override CMAKE_MODULE_PATH to prevent
# the maximum nesting/recursion depth error on some systems, like macOS.
set(_php_cmake_module_path ${CMAKE_MODULE_PATH})
unset(CMAKE_MODULE_PATH)
include(FindBISON)
set(CMAKE_MODULE_PATH ${_php_cmake_module_path})
unset(_php_cmake_module_path)

function(php_bison_target)
  message(WARNING "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXBISON is appending ${BISON_TARGET_outputs}")
  #add_custom_target(php_${NAME} DEPENDS BISON_TARGET_outputs)

  #add_custom_target(
  #  InstallFiles
  #  SOURCES
  #    $<TARGET_PROPERTY:InstallFiles,INSTALLED_FILES>
  #)
  set_property(
    TARGET php_generate_files
    APPEND PROPERTY SOURCES "${BISON_TARGET_outputs}"
  )
endfunction()

#variable_watch(BISON_TARGET_outputs php_bison_target)
