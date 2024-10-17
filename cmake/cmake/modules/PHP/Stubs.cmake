#[=============================================================================[
Generate *_arginfo.h headers from the *.stub.php sources

The build/gen_stub.php script requires the PHP tokenizer extension.
#]=============================================================================]

include_guard(GLOBAL)

# Store a list of all binary targets inside the given <dir> to the <result>
# variable.
function(_php_stubs_get_binary_targets result dir)
  get_property(targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
  get_property(subdirs DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)

  # Filter only binary targets.
  set(binaryTargets)
  foreach(target ${targets})
    get_target_property(type ${target} TYPE)
    if(type MATCHES "^((STATIC|MODULE|SHARED|OBJECT)_LIBRARY|EXECUTABLE)$")
      list(APPEND binaryTargets ${target})
    endif()
  endforeach()
  set(targets ${binaryTargets})

  foreach(subdir ${subdirs})
    cmake_language(CALL ${CMAKE_CURRENT_FUNCTION} subdirTargets ${subdir})
    list(APPEND targets ${subdirTargets})
  endforeach()

  set(${result} ${targets} PARENT_SCOPE)
endfunction()

# If PHP is not found on the system, the PHP cli SAPI will be used with the
# tokenizer extension.
if(NOT PHPSystem_EXECUTABLE AND NOT EXT_TOKENIZER AND NOT SAPI_CLI)
  return()
endif()

if(EXISTS ${PROJECT_SOURCE_DIR}/build/gen_stub.php)
  file(
    COPY
    ${PROJECT_SOURCE_DIR}/build/gen_stub.php
    DESTINATION ${PROJECT_BINARY_DIR}/build
  )
else()
  return()
endif()

block()
  _php_stubs_get_binary_targets(targets ${PROJECT_SOURCE_DIR})

  set(stubs)
  foreach(target ${targets})
    list(
      APPEND
      stubs
      $<PATH:ABSOLUTE_PATH,NORMALIZE,$<LIST:FILTER,$<TARGET_PROPERTY:${target},SOURCES>,INCLUDE,\.stub\.php$>,$<TARGET_PROPERTY:${target},SOURCE_DIR>>
    )

    if(PHPSystem_EXECUTABLE)
      add_dependencies(${target} php_stubs)
    endif()
  endforeach()

  file(
    GENERATE
    OUTPUT ${PROJECT_BINARY_DIR}/CMakeFiles/php_stubs.txt
    CONTENT "$<JOIN:$<REMOVE_DUPLICATES:${stubs}>,$<SEMICOLON>>"
  )

  set(PHP_COMMAND)

  if(PHPSystem_EXECUTABLE)
    set(PHP_COMMAND ${PHPSystem_EXECUTABLE})
  else()
    if(NOT CMAKE_CROSSCOMPILING)
      set(PHP_COMMAND $<TARGET_FILE:php_cli>)
    elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
      set(PHP_COMMAND ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:php_cli>)
    endif()
  endif()

  if(EXT_TOKENIZER_SHARED AND NOT PHPSystem_EXECUTABLE)
    list(
      APPEND
      PHP_COMMAND
      -d extension_dir=${PROJECT_BINARY_DIR}/modules
      -d extension=tokenizer
    )
  endif()

  if(NOT PHPSystem_EXECUTABLE)
    set(targetOptions ALL DEPENDS ${targets})
  endif()

  add_custom_target(
    php_stubs ${targetOptions}
    COMMAND
      ${CMAKE_COMMAND}
      "-DPHP_STUBS=${PROJECT_BINARY_DIR}/CMakeFiles/php_stubs.txt"
      "-DPHP_COMMAND=${PHP_COMMAND};${PROJECT_BINARY_DIR}/build/gen_stub.php"
      -P ${CMAKE_CURRENT_LIST_DIR}/Stubs/RunCommand.cmake
    VERBATIM
  )
endblock()
