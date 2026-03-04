#[=============================================================================[
Configuration common to all Unix-like operating systems.
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME MATCHES "^(Linux|SunOS|Haiku|FreeBSD)$")
  # POSIX.1c
  set(PHP_HAVE_GETPWNAM_R TRUE)
  set(PHP_HAVE_GETPWUID_R TRUE)

  # POSIX.1-2001 (XSI)
  set(PHP_HAVE_STRUCT_STAT_ST_BLKSIZE TRUE)
  set(PHP_HAVE_STRUCT_STAT_ST_BLOCKS TRUE)
  set(PHP_HAVE_STRUCT_STAT_ST_RDEV TRUE)
endif()
