#[=============================================================================[
Check Zend max execution timers.

The module defines the following variables if Zend max execution timers should
be enabled:

ZEND_MAX_EXECUTION_TIMERS
  Set to 1 if Zend max execution timers should be enabled.
]=============================================================================]#

include(CheckLibraryExists)
include(CheckSymbolExists)

message(STATUS "Checking whether to enable Zend max execution timers")

string(TOLOWER "${CMAKE_HOST_SYSTEM}" host_os)
if(NOT ${host_os} MATCHES ".*linux.*")
  set(ZEND_MAX_EXECUTION_TIMERS 0 CACHE BOOL "Whether to enable Zend max execution timers" FORCE)
endif()

# Check if timer_create() exists.
check_symbol_exists(timer_create time.h HAVE_TIMER_CREATE)

# Check for rt library.
if(NOT HAVE_TIMER_CREATE)
  check_library_exists(rt timer_create "" HAVE_TIMER_CREATE)

  if(HAVE_TIMER_CREATE)
    set(EXTRA_LIBS ${EXTRA_LIBS} rt)
  endif()
endif()

if(NOT HAVE_TIMER_CREATE)
  set(ZEND_MAX_EXECUTION_TIMERS 0 CACHE BOOL "Whether to enable Zend max execution timers" FORCE)
endif()

if(ZEND_MAX_EXECUTION_TIMERS)
  message(STATUS "Zend max execution timers are enabled")
  set(ZEND_MAX_EXECUTION_TIMERS 1 CACHE BOOL "Whether to enable Zend max execution timers" FORCE)
else()
  message(STATUS "Zend max execution timers are disabled")
endif()
