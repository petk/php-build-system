#[=============================================================================[
Find the sendmail program.

Result variables:

  Sendmail_FOUND
    Whether sendmail has been found.
  Sendmail_EXECUTABLE
    Path to the sendmail executable if found.

Cache variables:
  PROG_SENDMAIL
    Path to the sendmail program.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Sendmail PROPERTIES
  URL "https://sendmail.org"
  DESCRIPTION "Mail Transport Agent"
)

find_program(Sendmail_EXECUTABLE sendmail DOC "The sendmail executable path")

mark_as_advanced(Sendmail_EXECUTABLE)

if(Sendmail_EXECUTABLE)
  set(_sendmail ${Sendmail_EXECUTABLE})
else()
  set(_sendmail "/usr/sbin/sendmail")
endif()

set(PROG_SENDMAIL "${_sendmail}" CACHE INTERNAL "Path to sendmail executable")

find_package_handle_standard_args(
  Sendmail
  REQUIRED_VARS Sendmail_EXECUTABLE
  REASON_FAILURE_MESSAGE
    "sendmail not found, setting default to ${_sendmail}.
    It can be overridden in php.ini with sendmail_path directive."
)

unset(_sendmail)
