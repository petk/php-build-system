#[=============================================================================[
# FindSendmail

This module finds mailer program for PHP and sets sensible defaults based on the
target system. On Windows, PHP has built-in mailer (sendmail.c), on *nix systems
either `sendmail` is used if found, or a general default value is set to
`/usr/sbin/sendmail`.

## Result variables

* `Sendmail_FOUND` - Whether sendmail has been found.
* `PROG_SENDMAIL` - Path to the sendmail executable program, either found by
  the module or set to a sensible default value.

## Cache variables

* `Sendmail_EXECUTABLE` - Path to the sendmail executable program, if found.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Sendmail
  PROPERTIES
    URL "https://sendmail.org"
    DESCRIPTION "Mail Transport Agent"
)

set(_reason "")

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(_sendmailIsBuiltInMsg "PHP built-in mailer (Windows)")
  set(_sendmailRequiredVars _sendmailIsBuiltInMsg)
else()
  find_program(
    Sendmail_EXECUTABLE
    NAMES sendmail
    DOC "The path to the sendmail executable"
  )
  mark_as_advanced(Sendmail_EXECUTABLE)

  set(_sendmailRequiredVars Sendmail_EXECUTABLE)

  if(Sendmail_EXECUTABLE)
    set(PROG_SENDMAIL ${Sendmail_EXECUTABLE})
  else()
    set(PROG_SENDMAIL "/usr/sbin/sendmail")
  endif()

  set(
    _reason
    "sendmail not found. Default set to ${PROG_SENDMAIL}.
    It can be overridden with 'sendmail_path' php.ini directive."
  )
endif()

find_package_handle_standard_args(
  Sendmail
  REQUIRED_VARS ${_sendmailRequiredVars}
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)
unset(_sendmailIsBuiltInMsg)
unset(_sendmailRequiredVars)
