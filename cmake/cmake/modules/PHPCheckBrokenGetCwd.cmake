#[=============================================================================[
Some systems, notably Solaris, cause getcwd() or realpath to fail if a component
of the path has execute but not read permissions.

Module sets the following variables:

HAVE_BROKEN_GETCWD
  Set to 1 if system has broken getcwd().
]=============================================================================]#

message(STATUS "Checking for broken getcwd")

string(TOLOWER "${CMAKE_HOST_SYSTEM}" host_os)
if(${host_os} MATCHES "sunos.*")
  set(HAVE_BROKEN_GETCWD 1 CACHE INTERNAL "Define if system has broken getcwd")
  message(STATUS "yes")
else()
  message(STATUS "no")
endif()
