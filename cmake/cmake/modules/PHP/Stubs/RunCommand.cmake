#[=============================================================================[
Script for processing PHP stub sources.

Expected variables:

* PHP_COMMAND
* PHP_STUBS
#]=============================================================================]

if(NOT PHP_COMMAND OR NOT EXISTS "${PHP_STUBS}")
  return()
endif()

file(READ ${PHP_STUBS} sources)

foreach(stub ${sources})
  string(REGEX REPLACE [[\.stub\.php$]] "_arginfo.h" header "${stub}")
  if(${stub} IS_NEWER_THAN ${header})
    list(APPEND stubs ${stub})
  endif()
endforeach()

if(NOT stubs)
  return()
endif()

execute_process(
  COMMAND
    ${CMAKE_COMMAND}
      -E cmake_echo_color --blue --bold
      "Regenerating *_arginfo.h headers from *.stub.php sources"
)

execute_process(COMMAND ${PHP_COMMAND} ${stubs})

foreach(stub ${stubs})
  string(REGEX REPLACE [[\.stub\.php$]] "_arginfo.h" header "${stub}")
  if(
    EXISTS "${stub}"
    AND EXISTS "${header}"
    AND "${stub}" IS_NEWER_THAN "${header}"
  )
    file(TOUCH "${header}")
  endif()
endforeach()
