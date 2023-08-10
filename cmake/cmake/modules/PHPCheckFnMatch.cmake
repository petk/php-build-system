#[=============================================================================[
Checks for a working POSIX fnmatch() function.
]=============================================================================]#

if(CMAKE_CROSSCOMPILING)
  string(TOLOWER "${CMAKE_HOST_SYSTEM}" host_os)
  if(${host_os} MATCHES ".*linux.*")
    set(HAVE_FNMATCH 1 CACHE INTERNAL "Define to 1 if your system has a working POSIX fnmatch function.")
  endif()
else()
  # TODO: Add check for fnmatch() implementation on current platform.
endif()
