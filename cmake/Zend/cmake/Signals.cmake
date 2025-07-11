#[=============================================================================[
Check whether to enable Zend signals.
#]=============================================================================]

include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)

cmake_dependent_option(
  ZEND_SIGNALS
  "Enable Zend signal handling"
  ON
  [[NOT CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
mark_as_advanced(ZEND_SIGNALS)

message(CHECK_START "Checking whether to enable Zend signal handling")

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(HAVE_SIGACTION FALSE)
endif()

check_symbol_exists(sigaction signal.h HAVE_SIGACTION)

if(HAVE_SIGACTION AND ZEND_SIGNALS)
  message(CHECK_PASS "yes")

  # zend_config.h (or its wrapper php_config.h) isn't included in some zend_*
  # files, therefore also compilation definition is added.
  target_compile_definitions(zend PUBLIC ZEND_SIGNALS)
else()
  set(ZEND_SIGNALS OFF)
  message(CHECK_FAIL "no")
endif()

add_feature_info(
  "Zend signals"
  ZEND_SIGNALS
  "signal handling for performance"
)
