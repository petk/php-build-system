#[=============================================================================[
Find the sendmail program.

Result variables:
  Sendmail_FOUND
    Set to 1 if sendmail has been found.
  Sendmail_EXECUTABLE
    Path to the sendmail executable if found.

Cache variables:
  PROG_SENDMAIL
    Path to the sendmail program.
#]=============================================================================]

include(FindPackageHandleStandardArgs)

function(_php_find_sendmail)
  find_program(
    Sendmail_EXECUTABLE
    sendmail
    PATHS /usr/bin /usr/sbin /usr/etc /etc /usr/ucblib /usr/lib
    DOC "The sendmail executable path"
  )
  mark_as_advanced(Sendmail_EXECUTABLE)

  if(Sendmail_EXECUTABLE)
    set(sendmail ${Sendmail_EXECUTABLE})
  else()
    set(sendmail "/usr/sbin/sendmail")
  endif()

  set(PROG_SENDMAIL "${sendmail}" CACHE INTERNAL "Path to sendmail executable" FORCE)

  find_package_handle_standard_args(
    Sendmail
    REQUIRED_VARS Sendmail_EXECUTABLE
    REASON_FAILURE_MESSAGE "sendmail not found, setting default to ${PROG_SENDMAIL}, or use sendmail_path in php.ini"
  )
endfunction()

_php_find_sendmail()
