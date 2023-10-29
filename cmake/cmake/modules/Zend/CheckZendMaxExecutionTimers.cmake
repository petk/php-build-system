#[=============================================================================[
Check Zend max execution timers.

Cache variables:

  ZEND_MAX_EXECUTION_TIMERS
    Set to 1 if Zend max execution timers should be enabled.

  ZEND_MAX_EXECUTION_TIMERS_LIBRARIES
    Libraries for linking to target.
]=============================================================================]#

include(CheckLibraryExists)
include(CheckSymbolExists)

message(STATUS "Checking whether to enable Zend max execution timers")

if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
  message(STATUS "Zend max execution timers are disabled")
  set(ZEND_MAX_EXECUTION_TIMERS 0 CACHE BOOL "Whether to enable Zend max execution timers" FORCE)

  return()
endif()

# Check if timer_create() exists.
check_symbol_exists(timer_create time.h HAVE_TIMER_CREATE)

# Check for rt library.
if(NOT HAVE_TIMER_CREATE)
  check_library_exists(rt timer_create "" HAVE_TIMER_CREATE)

  if(HAVE_TIMER_CREATE)
    set(ZEND_MAX_EXECUTION_TIMERS_LIBRARIES rt)
  endif()
endif()

if(NOT HAVE_TIMER_CREATE)
  message(STATUS "Zend max execution timers are disabled")
  set(ZEND_MAX_EXECUTION_TIMERS 0 CACHE BOOL "Whether to enable Zend max execution timers" FORCE)

  return()
endif()

if(ZEND_MAX_EXECUTION_TIMERS)
  message(STATUS "Zend max execution timers are enabled")
  set(ZEND_MAX_EXECUTION_TIMERS 1 CACHE BOOL "Whether to enable Zend max execution timers" FORCE)
endif()
