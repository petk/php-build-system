#[=============================================================================[
# The pcntl extension

Configure the `pcntl` extension.

This extension provides support for process control support.

> [!NOTE]
> This extension is available only on \*nix systems.

> [!IMPORTANT]
> This extension should be used only with CLI-based PHP SAPIs.

## PHP_EXT_PCNTL

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PCNTL_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.2)

project(
  PhpExtensionPcntl
  LANGUAGES C
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckSymbolExists)
include(CheckTypeSize)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(PHP_EXT_PCNTL "Enable the pcntl extension (only for CLI-based SAPIs)")

add_feature_info(
  "ext/pcntl"
  PHP_EXT_PCNTL
  "process control support"
)

cmake_dependent_option(
  PHP_EXT_PCNTL_SHARED
  "Build the pcntl extension as a shared library"
  OFF
  PHP_EXT_PCNTL
  OFF
)

if(NOT PHP_EXT_PCNTL)
  return()
endif()

if(PHP_EXT_PCNTL_SHARED)
  add_library(php_ext_pcntl MODULE)
else()
  add_library(php_ext_pcntl OBJECT)
endif()

set_target_properties(php_ext_pcntl PROPERTIES PHP_CLI TRUE)

target_sources(
  php_ext_pcntl
  PRIVATE
    pcntl.c
    pcntl.stub.php
    php_signal.c
)

target_compile_definitions(php_ext_pcntl PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

# Check for required functions.
block()
  check_symbol_exists(fork unistd.h PHP_HAVE_FORK)
  check_symbol_exists(sigaction signal.h PHP_HAVE_SIGACTION)
  check_symbol_exists(waitpid sys/wait.h PHP_HAVE_WAITPID)

  foreach(function fork sigaction waitpid)
    string(TOUPPER ${function} const)
    if(NOT PHP_HAVE_${const})
      message(
        FATAL_ERROR
        "ext/pcntl: required function '${function}()' not found."
      )
    endif()
  endforeach()
endblock()

check_symbol_exists(forkx sys/fork.h PHP_EXT_PCNTL_HAVE_FORKX)
set(HAVE_FORKX ${PHP_EXT_PCNTL_HAVE_FORKX})

check_symbol_exists(getpriority sys/resource.h PHP_EXT_PCNTL_HAVE_GETPRIORITY)
set(HAVE_GETPRIORITY ${PHP_EXT_PCNTL_HAVE_GETPRIORITY})

check_symbol_exists(rfork unistd.h PHP_EXT_PCNTL_HAVE_RFORK)
set(HAVE_RFORK ${PHP_EXT_PCNTL_HAVE_RFORK})

check_symbol_exists(setpriority sys/resource.h PHP_EXT_PCNTL_HAVE_SETPRIORITY)
set(HAVE_SETPRIORITY ${PHP_EXT_PCNTL_HAVE_SETPRIORITY})

check_symbol_exists(sigtimedwait signal.h PHP_EXT_PCNTL_HAVE_SIGTIMEDWAIT)
set(HAVE_SIGTIMEDWAIT ${PHP_EXT_PCNTL_HAVE_SIGTIMEDWAIT})

check_symbol_exists(sigwaitinfo signal.h PHP_EXT_PCNTL_HAVE_SIGWAITINFO)
set(HAVE_SIGWAITINFO ${PHP_EXT_PCNTL_HAVE_SIGWAITINFO})

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_DEFINITIONS -D_GNU_SOURCE)
  check_symbol_exists(unshare sched.h PHP_EXT_PCNTL_HAVE_UNSHARE)
  set(HAVE_UNSHARE ${PHP_EXT_PCNTL_HAVE_UNSHARE})
cmake_pop_check_state()

check_symbol_exists(wait3 sys/wait.h PHP_EXT_PCNTL_HAVE_WAIT3)
set(HAVE_WAIT3 ${PHP_EXT_PCNTL_HAVE_WAIT3})

check_symbol_exists(wait4 sys/wait.h PHP_EXT_PCNTL_HAVE_WAIT4)
set(HAVE_WAIT4 ${PHP_EXT_PCNTL_HAVE_WAIT4})

cmake_push_check_state(RESET)
  set(CMAKE_EXTRA_INCLUDE_FILES "signal.h")
  check_type_size(siginfo_t PHP_EXT_PCNTL_STRUCT_SIGINFO_T)
cmake_pop_check_state()

if(HAVE_PHP_EXT_PCNTL_STRUCT_SIGINFO_T)
  target_compile_definitions(php_ext_pcntl PRIVATE HAVE_STRUCT_SIGINFO_T)
endif()

configure_file(cmake/config.h.in config.h)
