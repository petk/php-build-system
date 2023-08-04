#[=============================================================================[
CMake sendmail module to find the sendmail program.

The module defines the following variables

``PROG_SENDMAIL``
  path to the ``sendmail`` program

function: php_prog_sendmail

#]=============================================================================]

function(php_prog_sendmail)
  message(STATUS "Looking for sendmail")
  find_program(PROG_SENDMAIL sendmail PATHS /usr/bin /usr/sbin /usr/etc /etc /usr/ucblib /usr/lib)

  if(PROG_SENDMAIL)
    message(STATUS "Found sendmail at ${PROG_SENDMAIL}")
  else()
    message(STATUS "Setting default sendmail path ${PROG_SENDMAIL}")
    set(PROG_SENDMAIL /usr/sbin/sendmail CACHE INTERNAL "Path to sendmail executable" FORCE)
  endif()
endfunction()
