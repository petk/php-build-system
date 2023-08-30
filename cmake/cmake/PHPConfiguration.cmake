#[=============================================================================[
Project-wide configuration options and variables that can be overridden at the
configuration phase (cmake . -D...).
#]=============================================================================]

#[=============================================================================[
Customizable variables.
#]=============================================================================]
set(PHP_UNAME "" CACHE STRING "Build system uname")

if(CMAKE_UNAME AND NOT PHP_UNAME)
  execute_process(COMMAND ${CMAKE_UNAME} -a
          OUTPUT_VARIABLE PHP_UNAME
          OUTPUT_STRIP_TRAILING_WHITESPACE
          ERROR_QUIET)
endif()

set(PHP_BUILD_SYSTEM "${PHP_UNAME}" CACHE STRING "Build system uname")

set(PHP_BUILD_PROVIDER "" CACHE STRING "Build provider")

set(PHP_BUILD_COMPILER "" CACHE STRING "Compiler used for build")

set(PHP_BUILD_ARCH "" CACHE STRING "Build architecture")

set(PHP_LAYOUT "PHP" CACHE STRING
    "Set how installed files will be laid out. Type can be either PHP (default) or GNU")
set_property(CACHE PHP_LAYOUT PROPERTY STRINGS
             "GNU" "PHP")

set(PHP_EXTENSION_DIR "" CACHE STRING "The extension_dir PHP INI directive path")

#[=============================================================================[
General options.
#]=============================================================================]
option(RE2C_CGOTO "Whether to enable computed goto gcc extension with re2c" OFF)

option(DEBUG "Whether to include debugging symbols" OFF)

option(DEBUG_ASSERTIONS "Whether to enable debug assertions in release mode" OFF)

option(ZTS "Enable thread safety" OFF)

option(RTLD_NOW "Whether to dlopen extensions with RTLD_NOW instead of RTLD_LAZY" OFF)

option(SIGCHILD "Whether to enable PHP's own SIGCHLD handler" OFF)

option(SHORT_TAGS "Whether to enable the short-form <? start tag by default" ON)

option(IPV6 "Whether to enable IPv6 support" ON)

option(DTRACE "Whether to enable DTrace support" OFF)

set(FD_SETSIZE "" CACHE STRING "Size of descriptor sets")

option(VALGRIND "Whether to enable the valgring support" OFF)

option(BUILD_SHARED_LIBS "Whether to build all enabled optional PHP extensions as shared objects" OFF)

#[=============================================================================[
Zend options
#]=============================================================================]
option(GCC_GLOBAL_REGS "Whether to enable GCC global register variables" ON)

option(ZEND_SIGNALS "Whether to enable Zend signal handling" ON)

option(ZEND_MAX_EXECUTION_TIMERS "Whether to enable Zend max execution timers" ${ZTS})

if(DEBUG OR DEBUG_ASSERTIONS)
  set(ZEND_DEBUG 1)
else()
  set(ZEND_DEBUG 0)
endif()

if(ZTS)
  set(ZTS 1 CACHE BOOL "Whether thread safety is enabled" FORCE)
endif()

if(RTLD_NOW)
  set(PHP_USE_RTLD_NOW 1 CACHE INTERNAL "Use dlopen with RTLD_NOW instead of RTLD_LAZY")
endif()

if(SIGCHILD)
  set(PHP_SIGCHILD 1)
else()
  set(PHP_SIGCHILD 0)
endif()

if(SHORT_TAGS)
  set(DEFAULT_SHORT_OPEN_TAG "1")
else()
  set(DEFAULT_SHORT_OPEN_TAG "0")
endif()

if(FD_SETSIZE GREATER 0)
  set(EXTRA_DEFINITIONS ${EXTRA_DEFINITIONS} -DFD_SETSIZE=${FD_SETSIZE})
endif()