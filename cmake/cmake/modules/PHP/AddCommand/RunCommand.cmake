#[=============================================================================[
Script for PHP/AddCommand module that loops over output files and their
dependent input source files and runs the command inside the execute_process().

Expected input variables:

* PHP_COMMAND
* PHP_COMMENT
* PHP_DEPENDS
* PHP_EXECUTABLE
* PHP_OPTIONS
* PHP_OUTPUT
* PHP_WORKING_DIRECTORY
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

if(NOT CMAKE_SCRIPT_MODE_FILE OR NOT PHP_EXECUTABLE OR NOT PHP_COMMAND)
  return()
endif()

if(PHP_OUTPUT)
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
endif()

if(PHP_COMMENT)
  execute_process(
    COMMAND
      ${CMAKE_COMMAND} -E cmake_echo_color --blue --bold "${PHP_COMMENT}"
  )
endif()

set(args "")

if(PHP_WORKING_DIRECTORY)
  list(APPEND args WORKING_DIRECTORY ${PHP_WORKING_DIRECTORY})
endif()

set(php_command "")
set(output_redirected FALSE)
set(output_file "")

# The output redirection character '>' doesn't work inside execute_process. This
# bypasses such commands by capturing output into a variable and writes its
# content into a file.
foreach(php_arg ${PHP_COMMAND})
  if(php_arg STREQUAL ">")
    set(output_redirected TRUE)
    list(
      APPEND
      args
      RESULT_VARIABLE result
      OUTPUT_VARIABLE output
      ERROR_VARIABLE error
    )
  elseif(output_redirected AND NOT output_file)
    set(output_file ${php_arg})
  else()
    list(APPEND php_command ${php_arg})
  endif()
endforeach()

execute_process(
  COMMAND ${PHP_EXECUTABLE} ${PHP_OPTIONS} ${php_command}
  ${args}
)

if(output_redirected)
  if(result EQUAL 0 AND output_file)
    file(WRITE ${output_file} "${output}")
  else()
    execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${output}")
  endif()

  if(error)
    message(NOTICE "${error}")
  endif()
elseif(PHP_OUTPUT)
  # Update modification times of output files to not re-run the command on the
  # consecutive build runs.
  file(TOUCH_NOCREATE ${PHP_OUTPUT})
endif()
