#[=============================================================================[
Project-wide configuration options and variables that can be overridden at the
configuration phase via cmake-gui or command line:
  cmake -DPHP_OPTION=... -DZEND_OPTION=... -DEXT_... <path-to-source>

To see the list of customizable configuration variables with help texts:
  cmake -LH <path-to-source>

For the preferred configuration customization, opt for CMake presets:
  cmake --preset <preset>
#]=============================================================================]

################################################################################
# Customizable variables.
################################################################################

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

set(PHP_EXTENSION_DIR "" CACHE STRING "The extension_dir PHP INI directive absolute path")

option(PHP_WERROR "Enable the -Werror compiler option" OFF)

option(PHP_MEMORY_SANITIZER "Enable the memory sanitizer compiler options (clang only)" OFF)

option(PHP_ADDRESS_SANITIZER "Enable the address sanitizer compiler option" OFF)

option(PHP_UNDEFINED_SANITIZER "Enable the undefined sanitizer compiler option" OFF)

################################################################################
# General options.
################################################################################

option(PHP_RE2C_CGOTO "Enable computed goto GCC extension with re2c" OFF)

option(PHP_DEBUG "Include debugging symbols" OFF)

option(PHP_DEBUG_ASSERTIONS "Enable debug assertions in release mode" OFF)

option(PHP_ZTS "Enable thread safety" OFF)

option(PHP_USE_RTLD_NOW "Use dlopen with RTLD_NOW instead of RTLD_LAZY for extensions" OFF)

option(PHP_SIGCHILD "Enable PHP's own SIGCHLD handler" OFF)

option(PHP_SHORT_TAGS "Enable the short-form <? start tag by default" ON)

option(PHP_IPV6 "Enable IPv6 support" ON)

option(PHP_DTRACE "Enable DTrace support" OFF)

set(PHP_FD_SETSIZE "" CACHE STRING "Size of descriptor sets")

option(PHP_VALGRIND "Enable the Valgrind support" OFF)

option(BUILD_SHARED_LIBS "Build all enabled PHP extensions as shared libraries" OFF)

################################################################################
# Zend options.
################################################################################

option(ZEND_GCC_GLOBAL_REGS "Enable GCC global register variables" ON)

option(ZEND_FIBER_ASM "Enable the use of boost fiber assembly files" ON)

option(ZEND_SIGNALS "Enable Zend signal handling" ON)

option(ZEND_MAX_EXECUTION_TIMERS "Enable Zend max execution timers" ${PHP_ZTS})

if(PHP_ZTS)
  set(ZTS 1 CACHE BOOL "Whether thread safety is enabled" FORCE)
endif()

if(PHP_SHORT_TAGS)
  set(DEFAULT_SHORT_OPEN_TAG "1")
else()
  set(DEFAULT_SHORT_OPEN_TAG "0")
endif()

################################################################################
# Various global internal configuration.
################################################################################

# Minimum required version for the libxml2 dependency.
set(PHP_LIBXML2_MIN_VERSION 2.9.0)

# Minimum required version for the OpenSSL dependency.
set(PHP_OPENSSL_MIN_VERSION 1.0.2)
