#[=============================================================================[
Specific configuration for SunOS patform (Solaris, illumos, etc.).
]=============================================================================]#

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME STREQUAL "SunOS")
  # Issue a warning for Solaris 10 system on this build system due to too
  # possible compilation warnings and issues with outdated.
  if(CMAKE_SYSTEM_VERSION VERSION_LESS 5.11)
    message(
      WARNING
      "Solaris 10 with support from 2005 to 2027 might have a limited "
      "functionality. Check if you can upgrade to Solaris 11 or later, or try "
      "one of the illumos-based distributions."
    )
  endif()

  target_compile_definitions(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:_POSIX_PTHREAD_SEMANTICS>
  )
endif()
