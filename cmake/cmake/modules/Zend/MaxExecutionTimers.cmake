#[=============================================================================[
Check whether to enable Zend max execution timers.

## Cache variables

* [`ZEND_MAX_EXECUTION_TIMERS`](/docs/cmake/variables/ZEND_MAX_EXECUTION_TIMERS.md)

* `HAVE_TIMER_CREATE`

  Whether the system has `timer_create()`.

## Result variables

* `ZEND_MAX_EXECUTION_TIMERS`

  A regular variable based on the cache variable and thread safety to be able to
  run consecutive configuration runs. When `ZEND_MAX_EXECUTION_TIMERS` cache
  variable is set to 'auto', regular variable default value is set to the
  `PHP_THREAD_SAFETY` value.

## INTERFACE IMPORTED library

* `Zend::MaxExecutionTimers`

  Includes possible additional library to be linked for using `timer_create()`
  and a compile definition.
#]=============================================================================]

include_guard(GLOBAL)

message(CHECK_START "Checking whether to enable Zend max execution timers")

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  message(CHECK_FAIL "no")
  return()
endif()

include(PHP/SearchLibraries)
include(FeatureSummary)

set(
  ZEND_MAX_EXECUTION_TIMERS "auto"
  CACHE STRING "Enable Zend max execution timers"
)
mark_as_advanced(ZEND_MAX_EXECUTION_TIMERS)
set_property(
  CACHE ZEND_MAX_EXECUTION_TIMERS
  PROPERTY STRINGS "auto" "ON" "OFF"
)

# Set a regular variable based on the cache variable.
if(ZEND_MAX_EXECUTION_TIMERS STREQUAL "auto")
  set(ZEND_MAX_EXECUTION_TIMERS "${PHP_THREAD_SAFETY}")
else()
  set(ZEND_MAX_EXECUTION_TIMERS "${ZEND_MAX_EXECUTION_TIMERS}")
endif()

if(ZEND_MAX_EXECUTION_TIMERS AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
  php_search_libraries(
    timer_create
    HAVE_TIMER_CREATE
    HEADERS time.h
    LIBRARIES
      rt # Solaris <= 10, older Linux
    LIBRARY_VARIABLE libraryForTimerCreate
  )

  if(NOT HAVE_TIMER_CREATE)
    set(ZEND_MAX_EXECUTION_TIMERS OFF)
  endif()
else()
  set(ZEND_MAX_EXECUTION_TIMERS OFF)
endif()

if(ZEND_MAX_EXECUTION_TIMERS)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

add_feature_info(
  "Zend max execution timers"
  ZEND_MAX_EXECUTION_TIMERS
  "enhanced timeout and signal handling"
)

# Set the result variable also in the PARENT_SCOPE, to make it available for the
# parent project PHP in its configuration headers. This module is included in
# the Zend engine which is added with add_subdirectory() in the PHP project.
if(NOT PROJECT_IS_TOP_LEVEL)
  set(ZEND_MAX_EXECUTION_TIMERS ${ZEND_MAX_EXECUTION_TIMERS} PARENT_SCOPE)
endif()

add_library(Zend::MaxExecutionTimers INTERFACE IMPORTED)
if(libraryForTimerCreate)
  target_link_libraries(
    Zend::MaxExecutionTimers
    INTERFACE
      ${libraryForTimerCreate}
  )
endif()

# The configuration header with ZEND_MAX_EXECUTION_TIMERS might not be included
# in some source files, therefore also compilation definitions are added.
if(ZEND_MAX_EXECUTION_TIMERS)
  target_compile_definitions(
    Zend::MaxExecutionTimers
    INTERFACE
      ZEND_MAX_EXECUTION_TIMERS
  )
endif()
