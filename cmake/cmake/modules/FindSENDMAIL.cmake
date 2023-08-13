#[=============================================================================[
Module for finding the sendmail program.

The module sets the following variables:

``PROG_SENDMAIL``
  path to the ``sendmail`` program
#]=============================================================================]

include(FindPackageHandleStandardArgs)

function(php_find_sendmail)
  find_program(SENDMAIL_EXECUTABLE sendmail PATHS /usr/bin /usr/sbin /usr/etc /etc /usr/ucblib /usr/lib)
  mark_as_advanced(SENDMAIL_EXECUTABLE)

  if(SENDMAIL_EXECUTABLE)
    set(PROG_SENDMAIL ${SENDMAIL_EXECUTABLE})
  else()
    set(PROG_SENDMAIL "/usr/sbin/sendmail")
  endif()

  set(PROG_SENDMAIL "${PROG_SENDMAIL}" CACHE INTERNAL "Path to sendmail executable" FORCE)

  find_package_handle_standard_args(
    SENDMAIL
    REQUIRED_VARS SENDMAIL_EXECUTABLE
    REASON_FAILURE_MESSAGE "sendmail not found, setting default to ${PROG_SENDMAIL}, or use sendmail_path in php.ini"
  )
endfunction()

php_find_sendmail()
