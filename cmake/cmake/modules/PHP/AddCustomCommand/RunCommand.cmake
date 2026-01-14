#[=============================================================================[
Script for PHP/AddCustomCommand module that loops over output files and their
dependent input source files and runs the command inside the execute_process().

Expected input variables:

* PHP_COMMAND
* PHP_COMMENT
* PHP_DEPENDS
* PHP_EXECUTABLE
* PHP_OPTIONS
* PHP_OUTPUT
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

if(NOT CMAKE_SCRIPT_MODE_FILE OR NOT PHP_EXECUTABLE OR NOT PHP_COMMAND)
  return()
endif()

set(needs_update FALSE)

foreach(input ${PHP_DEPENDS})
  if(NOT EXISTS ${input})
    continue()
  endif()

  foreach(output ${PHP_OUTPUT})
    if("${input}" IS_NEWER_THAN "${output}")
      set(needs_update TRUE)
      break()
    endif()
  endforeach()

  if(needs_update)
    break()
  endif()
endforeach()

if(NOT needs_update)
  return()
endif()

if(PHP_COMMENT)
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -E cmake_echo_color --blue --bold "       ${PHP_COMMENT}"
  )
endif()

execute_process(COMMAND ${PHP_EXECUTABLE} ${PHP_OPTIONS} ${PHP_COMMAND})

# Update modification times of output files to not re-run the command on the
# consecutive build runs.
file(TOUCH_NOCREATE ${PHP_OUTPUT})
