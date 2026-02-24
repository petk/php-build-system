#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It generates *_arginfo.h headers from the *.stub.php sources.

Load this module in a CMake project with:

  include(PHP/Internal/Stubs)

The build/gen_stub.php script requires the PHP tokenizer extension. The
PHP-Parser additionally requires the PHP ctype extension but it is not needed
to generate the stubs.
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
    AND NOT TARGET PHP::Interpreter
  )
    return(PROPAGATE ${result})
  endif()

  # If external PHP is available, check for the required tokenizer extension.
  if(PHP_HOST_FOUND OR TARGET PHP::Interpreter)
    if(TARGET PHP::Interpreter)
      get_target_property(php_executable PHP::Interpreter LOCATION)
    else()
      set(php_executable "${PHP_HOST_EXECUTABLE}")
    endif()

    execute_process(
      COMMAND ${php_executable} --ri tokenizer
      RESULT_VARIABLE code
      OUTPUT_QUIET
      ERROR_QUIET
    )

    if(code EQUAL 0)
      set(${result} ${php_executable})
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

# When building standalone PHP extension or php-src.
if(
  (
    TARGET PHP::Interpreter
    AND NOT EXISTS ${PHP_INSTALL_LIBDIR}/build/gen_stub.php
  )
  OR (
    NOT TARGET PHP::Interpreter
    AND NOT EXISTS ${PROJECT_SOURCE_DIR}/build/gen_stub.php
  )
)
  return()
endif()

block()
  if(TARGET PHP::Interpreter)
    set(php_gen_stub_script_source ${PHP_INSTALL_LIBDIR}/build/gen_stub.php)
  else()
    set(php_gen_stub_script_source ${PROJECT_SOURCE_DIR}/build/gen_stub.php)
  endif()

  file(
    COPY
    ${php_gen_stub_script_source}
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/Stubs
  )

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

    if(PHP_HOST_FOUND OR TARGET PHP::Interpreter)
      add_dependencies(${target} php_stubs)
    endif()
  endforeach()

  # Create a script for processing PHP stub sources.
  string(CONFIGURE [=[
    cmake_minimum_required(VERSION 4.2...4.3)

    if(NOT CMAKE_SCRIPT_MODE_FILE)
      message(FATAL_ERROR "This is a command-line script.")
    endif()

    if(NOT PHP_COMMAND)
      message(WARNING "StubsGenerator.cmake: No PHP command given.")
      return()
    endif()

    set(sources "$<JOIN:$<REMOVE_DUPLICATES:@stubs@>,$<SEMICOLON>>")

    # Ensure sources include only *.stub.php files.
    list(FILTER sources INCLUDE REGEX [[\.stub\.php$]])

    # Create a list of sources that must be parsed by the generator.
    if("@php_gen_stub_script_source@" IS_NEWER_THAN ${CMAKE_CURRENT_LIST_FILE})
      file(
        COPY
        "@php_gen_stub_script_source@"
        DESTINATION ${CMAKE_CURRENT_LIST_DIR}
      )
      set(stubs ${sources})
      file(TOUCH ${CMAKE_CURRENT_LIST_FILE})
    else()
      foreach(stub ${sources})
        string(REGEX REPLACE [[\.stub\.php$]] [[_arginfo.h]] header "${stub}")
        if("${stub}" IS_NEWER_THAN "${header}")
          list(APPEND stubs ${stub})
        endif()
      endforeach()
    endif()

    if(NOT stubs)
      return()
    endif()

    execute_process(
      COMMAND
        ${CMAKE_COMMAND} -E cmake_echo_color --blue --bold
          "Regenerating *_arginfo.h headers from *.stub.php sources"
      COMMAND
        ${PHP_COMMAND} ${CMAKE_CURRENT_LIST_DIR}/gen_stub.php ${stubs}
    )

    # Ensure that *_arginfo.h headers are newer than their *.stub.php sources.
    foreach(stub ${stubs})
      string(REGEX REPLACE [[\.stub\.php$]] [[_arginfo.h]] header "${stub}")
      if("${stub}" IS_NEWER_THAN "${header}")
        file(TOUCH "${header}")
      endif()
    endforeach()
  ]=] content @ONLY)

  file(
    GENERATE
    OUTPUT ${PROJECT_BINARY_DIR}/CMakeFiles/PHP/Stubs/StubsGenerator.cmake
    CONTENT "${content}"
  )

  set(target_options "")
  if(NOT PHP_HOST_FOUND AND NOT TARGET PHP::Interpreter)
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
