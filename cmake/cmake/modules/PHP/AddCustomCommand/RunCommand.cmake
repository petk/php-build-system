#[=============================================================================[
Script for PHP/AddCustomCommand module that loops over output files and their
dependent input source files and runs the command inside the execute_process().

Expected variables:

* COMMENT - String printed in the build output log.
* DEPENDS - A list of dependent files.
* OUTPUT - A list of output files to be produced.
* PHP_COMMAND - A list of command and its arguments.
#]=============================================================================]

if(NOT CMAKE_SCRIPT_MODE_FILE OR NOT PHP_COMMAND)
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

execute_process(
  COMMAND ${PHP_COMMAND}
  RESULT_VARIABLE result
  ERROR_VARIABLE error
)

if(NOT result EQUAL 0)
  list(JOIN PHP_COMMAND " " command)
  message(NOTICE "Command ended with non-zero status:\n  ${command}\n${error}")
endif()

# Update modification times of output files to not re-run the command on the
# consecutive build runs.
file(TOUCH_NOCREATE ${OUTPUT})
