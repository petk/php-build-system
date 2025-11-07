#[=============================================================================[
Check whether to enable Zend signals.
#]=============================================================================]

include(CheckSymbolExists)
include(FeatureSummary)

set(ZEND_SIGNALS FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

message(CHECK_START "Checking whether to enable Zend signal handling")

check_symbol_exists(sigaction signal.h PHP_HAVE_SIGACTION)
set(HAVE_SIGACTION ${PHP_HAVE_SIGACTION})

if(PHP_HAVE_SIGACTION AND PHP_ZEND_SIGNALS)
  message(CHECK_PASS "yes")
  set(ZEND_SIGNALS TRUE)

  # zend_config.h (or its wrapper php_config.h) isn't included in some zend_*
  # files, therefore also compilation definition is added.
  target_compile_definitions(php_zend PUBLIC ZEND_SIGNALS)
else()
  message(CHECK_FAIL "no")
  set(ZEND_SIGNALS FALSE)
endif()

add_feature_info(
  "Zend signals"
  ZEND_SIGNALS
  "signal handling for performance"
)
