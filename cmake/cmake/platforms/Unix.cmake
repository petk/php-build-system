#[=============================================================================[
Configuration common to all Unix-like operating systems.
#]=============================================================================]

include_guard(GLOBAL)

if(CMAKE_SYSTEM_NAME MATCHES "^(Linux|SunOS|Haiku|FreeBSD)$")
  # POSIX.1c
  set(PHP_HAVE_GETPWNAM_R TRUE)
  set(PHP_HAVE_GETPWUID_R TRUE)

  # Since issue 4, version 2 in XSI, as of issue 7 in base POSIX.
  set(PHP_HAVE_POLL TRUE)
  set(PHP_HAVE_POLL_H TRUE)

  # POSIX.1-2001 (XSI)
  set(PHP_HAVE_STRUCT_STAT_ST_BLKSIZE TRUE)
  set(PHP_HAVE_STRUCT_STAT_ST_BLOCKS TRUE)
  set(PHP_HAVE_STRUCT_STAT_ST_RDEV TRUE)

  set(PHP_HAVE_GRP_H TRUE)
  set(PHP_HAVE_PWD_H TRUE)
  set(PHP_HAVE_SYS_PARAM_H TRUE)
  set(PHP_HAVE_SYS_RESOURCE_H TRUE)
  set(PHP_HAVE_SYS_SELECT_H TRUE)
  set(PHP_HAVE_SYS_SOCKET_H TRUE)
  set(PHP_HAVE_SYS_STAT_H TRUE)
  set(PHP_HAVE_SYS_TIME_H TRUE)
  set(PHP_HAVE_SYS_TYPES_H TRUE)
  set(PHP_HAVE_SYS_UIO_H TRUE)
  set(PHP_HAVE_UNISTD_H TRUE)
endif()
