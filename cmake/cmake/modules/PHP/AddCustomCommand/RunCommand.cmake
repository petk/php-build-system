#[=============================================================================[
Script for PHP/AddCustomCommand module that loops over output files and their
dependent input source files and runs the command inside the execute_process().

Expected variables:

* PHP_EXECUTABLE
* PHP_COMMAND
* DEPENDS
* OUTPUT
* COMMENT
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.1)

if(NOT CMAKE_SCRIPT_MODE_FILE OR NOT PHP_EXECUTABLE OR NOT PHP_COMMAND)
  return()
endif()

set(needsUpdate FALSE)

foreach(input ${DEPENDS})
  if(NOT EXISTS ${input})
    continue()
  endif()

  foreach(output ${OUTPUT})
    if("${input}" IS_NEWER_THAN "${output}")
      set(needsUpdate TRUE)
      break()
    endif()
  endforeach()

  if(needsUpdate)
    break()
  endif()
endforeach()

if(NOT needsUpdate)
  return()
endif()

if(COMMENT)
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -E cmake_echo_color --blue --bold "       ${COMMENT}"
  )
endif()

execute_process(COMMAND ${PHP_EXECUTABLE} ${PHP_COMMAND})

# Update modification times of output files to not re-run the command on the
# consecutive build runs.
file(TOUCH_NOCREATE ${OUTPUT})
