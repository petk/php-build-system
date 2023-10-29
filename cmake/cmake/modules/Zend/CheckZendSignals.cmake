#[=============================================================================[
Check whether to enable Zend signal handling.

Cache variables:

  ZEND_SIGNALS
    Set to 1 when using Zend signal handling.

  HAVE_SIGACTION
    Set to 1 if the sigaction symbol is available.
]=============================================================================]#

include(CheckSymbolExists)

message(STATUS "Checking whether to enable Zend signal handling")

check_symbol_exists(sigaction "signal.h" HAVE_SIGACTION)

if(NOT HAVE_SIGACTION OR NOT ZEND_SIGNALS)
  message(STATUS "Zend signals are disabled")
  set(ZEND_SIGNALS 0 CACHE BOOL "Whether to enable Zend signal handling" FORCE)
else()
  message(STATUS "Zend signals are enabled")
  set(ZEND_SIGNALS 1 CACHE BOOL "Whether to enable Zend signal handling" FORCE)
endif()
