#[=============================================================================[
Check whether to enable Zend max execution timers.

Result variables:

* ZEND_MAX_EXECUTION_TIMERS

  A local variable based on the configuration variable and thread safety to be
  able to run consecutive configuration phases. When
  PHP_ZEND_MAX_EXECUTION_TIMERS variable is set to 'auto',
  ZEND_MAX_EXECUTION_TIMERS default value is set to the value of
  PHP_THREAD_SAFETY variable.
#]=============================================================================]

include(FeatureSummary)
include(PHP/SearchLibraries)

set(ZEND_MAX_EXECUTION_TIMERS FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

message(CHECK_START "Checking whether to enable Zend max execution timers")

# Set a local variable based on the cache variable.
if(PHP_ZEND_MAX_EXECUTION_TIMERS STREQUAL "auto")
  set(ZEND_MAX_EXECUTION_TIMERS "${PHP_THREAD_SAFETY}")
else()
  set(ZEND_MAX_EXECUTION_TIMERS "${PHP_ZEND_MAX_EXECUTION_TIMERS}")
endif()

if(ZEND_MAX_EXECUTION_TIMERS AND CMAKE_SYSTEM_NAME MATCHES "^(Linux|FreeBSD)$")
  php_search_libraries(
    SYMBOL timer_create
    HEADERS time.h
    LIBRARIES
      rt # Solaris <= 10, older Linux
    RESULT_VARIABLE PHP_ZEND_HAVE_TIMER_CREATE
    LIBRARY_VARIABLE PHP_ZEND_HAVE_TIMER_CREATE_LIBRARY
  )

  if(NOT PHP_ZEND_HAVE_TIMER_CREATE)
    set(ZEND_MAX_EXECUTION_TIMERS FALSE)
  endif()
else()
  set(ZEND_MAX_EXECUTION_TIMERS FALSE)
endif()

if(ZEND_MAX_EXECUTION_TIMERS)
  if(PHP_ZEND_HAVE_TIMER_CREATE_LIBRARY)
    target_link_libraries(php_zend PUBLIC ${PHP_ZEND_HAVE_TIMER_CREATE_LIBRARY})
  endif()

  # zend_config.h (or its parent php_config.h) isn't included in some files,
  # therefore also compilation definition is added.
  target_compile_definitions(php_zend PUBLIC ZEND_MAX_EXECUTION_TIMERS)

  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

add_feature_info(
  "Zend max execution timers"
  ZEND_MAX_EXECUTION_TIMERS
  "enhanced timeout and signal handling"
)
