#[=============================================================================[
Rebuild all project targets.

When PHP is not found on the system, PHP generates some files during development
using the php_cli target itself, which can bring cyclic dependencies among
targets if custom commands would depend on the php_cli target. Although not a
good practice, this helps bringing all targets to updated state.
#]=============================================================================]

include_guard(GLOBAL)

# Store a list of all targets inside the given <dir> into the <result> variable.
function(_php_get_all_targets result dir)
  get_property(targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
  get_property(subdirs DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)

  foreach(subdir ${subdirs})
    cmake_language(CALL ${CMAKE_CURRENT_FUNCTION} subdirTargets ${subdir})
    list(APPEND targets ${subdirTargets})
  endforeach()

  set(${result} ${targets} PARENT_SCOPE)
endfunction()

# Ensure all project targets are rebuilt as needed.
function(_php_rebuild)
  _php_get_all_targets(targets ${CMAKE_CURRENT_SOURCE_DIR})
  list(REMOVE_ITEM targets "php_rebuild")

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_rebuild.timestamp
    COMMAND
      ${CMAKE_COMMAND}
        -E cmake_echo_color --magenta --bold "       Updating targets"
    COMMAND
      ${CMAKE_COMMAND}
        -E touch ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_rebuild.timestamp
    COMMAND
      ${CMAKE_COMMAND}
        --build . --target php_rebuild -j
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    DEPENDS ${targets}
  )

  add_custom_target(
    php_update_targets ALL
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_rebuild.timestamp
  )

  add_custom_target(
    php_rebuild
    COMMAND
      ${CMAKE_COMMAND}
        -E rm -f ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_rebuild.timestamp
    DEPENDS ${targets}
  )
endfunction()

# Run at the end of the configuration.
cmake_language(
  DEFER
    DIRECTORY ${PROJECT_SOURCE_DIR}
  CALL _php_rebuild
)
