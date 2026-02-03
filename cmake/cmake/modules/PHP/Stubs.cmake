#[=============================================================================[
# PHP/Stubs

Generate *_{arginfo,decl}.h headers from the *.stub.php sources

The build/gen_stub.php script requires the PHP tokenizer extension.

## Usage

```cmake
# CMakeLists.txt
include(PHP/Stubs)
```
#]=============================================================================]

include_guard(GLOBAL)

# Get a PHP command for parsing stub sources.
function(_php_stubs_get_php_command result)
  unset(${result})

  # If PHP is not found on the system, the PHP cli SAPI will be used with the
  # tokenizer extension.
  if(
    NOT PHP_HOST_FOUND
    AND (
      NOT TARGET PHP::sapi::cli
      OR (TARGET PHP::sapi::cli AND NOT TARGET PHP::ext::tokenizer)
    )
  )
    return(PROPAGATE ${result})
  endif()

  # If external PHP is available, check for the required tokenizer extension.
  if(PHP_HOST_FOUND)
    execute_process(
      COMMAND ${PHP_HOST_EXECUTABLE} --ri tokenizer
      RESULT_VARIABLE code
      OUTPUT_QUIET
      ERROR_QUIET
    )

    if(code EQUAL 0)
      set(${result} ${PHP_HOST_EXECUTABLE})
      return(PROPAGATE ${result})
    endif()
  endif()

  if(NOT CMAKE_CROSSCOMPILING)
    set(command $<TARGET_FILE:PHP::sapi::cli>)
  elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
    set(command ${CMAKE_CROSSCOMPILING_EMULATOR} $<TARGET_FILE:PHP::sapi::cli>)
  else()
    return(PROPAGATE ${result})
  endif()

  get_target_property(type PHP::ext::tokenizer TYPE)
  if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    list(
      APPEND
      command
      -d extension_dir=${PROJECT_BINARY_DIR}/modules/$<CONFIG>
      -d extension=tokenizer
    )
  endif()

  set(${result} ${command})
  return(PROPAGATE ${result})
endfunction()

# Store a list of all binary targets inside the given <dir> to the <result>
# variable.
function(_php_stubs_get_binary_targets result dir)
  get_property(targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
  get_property(subdirs DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)

  # Filter only binary targets.
  set(binary_targets "")
  foreach(target ${targets})
    get_target_property(type ${target} TYPE)
    if(type MATCHES "^((STATIC|MODULE|SHARED|OBJECT)_LIBRARY|EXECUTABLE)$")
      list(APPEND binary_targets ${target})
    endif()
  endforeach()
  set(targets ${binary_targets})

  foreach(subdir ${subdirs})
    cmake_language(CALL ${CMAKE_CURRENT_FUNCTION} sub_dir_targets ${subdir})
    list(APPEND targets ${sub_dir_targets})
  endforeach()

  set(${result} ${targets})
  return(PROPAGATE ${result})
endfunction()

if(NOT EXISTS ${PROJECT_SOURCE_DIR}/build/gen_stub.php)
  return()
endif()

file(
  COPY
  ${PROJECT_SOURCE_DIR}/build/gen_stub.php
  DESTINATION ${PROJECT_BINARY_DIR}/CMakeFiles/PHP/Stubs
)

block()
  _php_stubs_get_php_command(PHP_COMMAND)

  if(NOT PHP_COMMAND)
    return()
  endif()

  _php_stubs_get_binary_targets(targets ${PROJECT_SOURCE_DIR})

  set(stubs "")
  foreach(target ${targets})
    list(
      APPEND
      stubs
      $<PATH:ABSOLUTE_PATH,NORMALIZE,$<LIST:FILTER,$<TARGET_PROPERTY:${target},SOURCES>,INCLUDE,\.stub\.php$>,$<TARGET_PROPERTY:${target},SOURCE_DIR>>
    )

    if(PHP_HOST_FOUND)
      add_dependencies(${target} php_stubs)
    endif()
  endforeach()

  set(PHP_SOURCES "$<JOIN:$<REMOVE_DUPLICATES:${stubs}>,$<SEMICOLON>>")
  file(READ ${CMAKE_CURRENT_LIST_DIR}/Stubs/StubsGenerator.cmake.in content)
  string(CONFIGURE "${content}" content @ONLY)
  file(
    GENERATE
    OUTPUT ${PROJECT_BINARY_DIR}/CMakeFiles/PHP/Stubs/StubsGenerator.cmake
    CONTENT "${content}"
  )

  set(target_options "")
  if(NOT PHP_HOST_FOUND)
    set(target_options ALL DEPENDS ${targets})
  endif()

  add_custom_target(
    php_stubs ${target_options}
    COMMAND
      ${CMAKE_COMMAND}
      -D "PHP_COMMAND=${PHP_COMMAND}"
      -P ${PROJECT_BINARY_DIR}/CMakeFiles/PHP/Stubs/StubsGenerator.cmake
    VERBATIM
  )
endblock()
