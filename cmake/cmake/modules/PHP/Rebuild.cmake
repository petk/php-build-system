#[=============================================================================[
Ensure all project targets are rebuilt as needed.

When PHP is not found on the system, the `php_cli` target is used to generate
certain files during development. This can lead to cyclic dependencies among
targets if custom commands depend on the `php_cli` target. While such automatic
rebuilding is not considered good practice, it ensures that all targets are kept
up to date.

TODO: This works only for a limited set of cases for now and will be refactored.
#]=============================================================================]

include_guard(GLOBAL)

# Store a list of all targets inside the given <dir> into the <result> variable.
function(_php_rebuild_get_all_targets result dir)
  get_property(targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
  get_property(subdirs DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)

  foreach(subdir ${subdirs})
    cmake_language(CALL ${CMAKE_CURRENT_FUNCTION} subdirTargets ${subdir})
    list(APPEND targets ${subdirTargets})
  endforeach()

  set(${result} ${targets} PARENT_SCOPE)
endfunction()

_php_rebuild_get_all_targets(targets ${CMAKE_CURRENT_SOURCE_DIR})

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_rebuild.timestamp
  COMMAND
    ${CMAKE_COMMAND}
      -E cmake_echo_color --magenta --bold "Updating targets"
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
  php_rebuild_update_targets ALL
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_rebuild.timestamp
)

add_custom_target(
  php_rebuild
  COMMAND
    ${CMAKE_COMMAND}
      -E rm -f ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/php_rebuild.timestamp
  DEPENDS ${targets}
)
