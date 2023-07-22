#[=============================================================================[
Checks whether to enable Zend signal handling.

The module defines the following variables:

``ZEND_SIGNALS``
  Defined to 1 when using zend signal handling

``HAVE_SIGACTION``
  Defined to 1 if the sigaction symbol is available.
]=============================================================================]#

include(CheckSymbolExists)

message(STATUS "Checking whether to enable zend signal handling")
option(zend_signals "Whether to enable zend signal handling" ON)

check_symbol_exists(sigaction "signal.h" HAVE_SIGACTION)

if(NOT HAVE_SIGACTION)
  set(zend_signals OFF)
endif()

if(zend_signals)
  set(ZEND_SIGNALS 1 CACHE STRING "Use zend signal handling")
endif()

message(STATUS ${zend_signals})
