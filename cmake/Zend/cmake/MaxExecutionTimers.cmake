#[=============================================================================[
# MaxExecutionTimers

Check whether to enable Zend max execution timers.

## Cache variables

* `ZEND_MAX_EXECUTION_TIMERS`

* `HAVE_TIMER_CREATE`

  Whether the system has `timer_create()`.

## Result variables

* `ZEND_MAX_EXECUTION_TIMERS`

  A local variable based on the cache variable and thread safety to be able to
  run consecutive configuration phases. When `ZEND_MAX_EXECUTION_TIMERS` cache
  variable is set to 'auto', local variable default value is set to the
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

include(FeatureSummary)
include(PHP/SearchLibraries)

set(
  ZEND_MAX_EXECUTION_TIMERS "auto"
  CACHE STRING "Enable Zend max execution timers"
)
mark_as_advanced(ZEND_MAX_EXECUTION_TIMERS)
set_property(
  CACHE ZEND_MAX_EXECUTION_TIMERS
  PROPERTY STRINGS "auto" "ON" "OFF"
)

# Set a local variable based on the cache variable.
if(ZEND_MAX_EXECUTION_TIMERS STREQUAL "auto")
  set(ZEND_MAX_EXECUTION_TIMERS "${PHP_THREAD_SAFETY}")
else()
  set(ZEND_MAX_EXECUTION_TIMERS "${ZEND_MAX_EXECUTION_TIMERS}")
endif()

if(ZEND_MAX_EXECUTION_TIMERS AND CMAKE_SYSTEM_NAME STREQUAL "Linux")
  php_search_libraries(
    timer_create
    HEADERS time.h
    LIBRARIES
      rt # Solaris <= 10, older Linux
    VARIABLE HAVE_TIMER_CREATE
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

add_library(Zend::MaxExecutionTimers INTERFACE IMPORTED GLOBAL)
if(libraryForTimerCreate)
  target_link_libraries(
    Zend::MaxExecutionTimers
    INTERFACE
      ${libraryForTimerCreate}
  )
endif()

# zend_config.h (or its parent php_config.h) isn't included in some zend_*
# files, therefore also compilation definition is added.
if(ZEND_MAX_EXECUTION_TIMERS)
  target_compile_definitions(
    Zend::MaxExecutionTimers
    INTERFACE
      ZEND_MAX_EXECUTION_TIMERS
  )
endif()
