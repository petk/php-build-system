#[=============================================================================[
Configuration common to all Unix-like operating systems.
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME MATCHES "^(Linux|SunOS|Haiku|FreeBSD)$")
  # POSIX.1c
  set(PHP_HAVE_GETPWNAM_R TRUE)
  set(PHP_HAVE_GETPWUID_R TRUE)
endif()
