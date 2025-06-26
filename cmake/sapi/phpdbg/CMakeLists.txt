#[=============================================================================[
# The phpdbg SAPI

Configure the `phpdbg` (interactive PHP debugger) PHP SAPI.

## PHP_SAPI_PHPDBG

* Default: `ON`
* Values: `ON|OFF`

Enable the phpdbg SAPI module as an executable.

## PHP_SAPI_PHPDBG_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build phpdbg SAPI also as a shared module together with an executable.

The phpdbg shared library is after the build phase located in the `sapi/phpdbg`
directory:

* `libphpdbg.so` (\*nix), or `libphpdbg.dylib` (macOS), or `libphpdbg.dll`
  (Windows)

## PHP_SAPI_PHPDBG_DEBUG

* Default: `OFF`
* Values: `ON|OFF`

Build phpdbg in debug mode to enable additional diagnostic output for developing
and troubleshooting phpdbg itself.

## PHP_SAPI_PHPDBG_READLINE

* Default: `OFF`
* Values: `ON|OFF`

Explicitly enable readline support in phpdbg for command history accessible
through arrow keys. Requires the Editline library. If the PHP extension
`readline` is enabled during the build process, the phpdbg readline support is
automatically enabled regardless of this option.

Where to find the Editline installation on the system, can be customized with
the `EDITLINE_ROOT` variable.
#]=============================================================================]

include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/Install)

################################################################################
# Configuration options.
################################################################################

option(PHP_SAPI_PHPDBG "Enable the phpdbg SAPI module" ON)
add_feature_info(
  "sapi/phpdbg"
  PHP_SAPI_PHPDBG
  "interactive PHP debugger"
)

cmake_dependent_option(
  PHP_SAPI_PHPDBG_SHARED
  "Build phpdbg SAPI as a shared module"
  OFF
  PHP_SAPI_PHPDBG
  OFF
)
mark_as_advanced(PHP_SAPI_PHPDBG_SHARED)
add_feature_info(
  "sapi/phpdbg shared"
  PHP_SAPI_PHPDBG_SHARED
  "dynamically loadable shared object"
)

cmake_dependent_option(
  PHP_SAPI_PHPDBG_DEBUG
  "Enable additional diagnostic output when developing phpdbg itself"
  OFF
  PHP_SAPI_PHPDBG
  OFF
)
mark_as_advanced(PHP_SAPI_PHPDBG_DEBUG)
add_feature_info(
  "sapi/phpdbg debug"
  PHP_SAPI_PHPDBG_DEBUG
  "additional diagnostic output"
)

cmake_dependent_option(
  PHP_SAPI_PHPDBG_READLINE
  "Explicitly enable readline support in phpdbg"
  OFF
  PHP_SAPI_PHPDBG
  OFF
)
mark_as_advanced(PHP_SAPI_PHPDBG_READLINE)

if(NOT PHP_SAPI_PHPDBG)
  return()
endif()

################################################################################
# Executable and library.
################################################################################

add_executable(php_sapi_phpdbg)
add_executable(PHP::sapi::phpdbg ALIAS php_sapi_phpdbg)

if(PHP_SAPI_PHPDBG_SHARED)
  add_library(php_sapi_phpdbg_shared SHARED)
  add_library(PHP::sapi::phpdbg_shared ALIAS php_sapi_phpdbg_shared)
endif()

foreach(target IN ITEMS php_sapi_phpdbg php_sapi_phpdbg_shared)
  if(NOT TARGET ${target})
    continue()
  endif()

  target_sources(
    ${target}
    PRIVATE
      phpdbg_bp.c
      phpdbg_break.c
      phpdbg_btree.c
      phpdbg_cmd.c
      phpdbg_frame.c
      phpdbg_help.c
      phpdbg_info.c
      phpdbg_io.c
      phpdbg_lexer.c
      phpdbg_list.c
      phpdbg_out.c
      phpdbg_parser.c
      phpdbg_print.c
      phpdbg.stub.php
      phpdbg_prompt.c
      phpdbg_set.c
      phpdbg_sigsafe.c
      phpdbg_utils.c
      phpdbg_watch.c
      $<$<PLATFORM_ID:Windows>:phpdbg_win.c>
      phpdbg.c
  )

  target_compile_definitions(
    ${target}
    PRIVATE
      ZEND_ENABLE_STATIC_TSRMLS_CACHE
      $<$<PLATFORM_ID:Windows>:YY_NO_UNISTD_H>
      $<IF:$<BOOL:${PHP_SAPI_PHPDBG_DEBUG}>,PHPDBG_DEBUG=1,PHPDBG_DEBUG=0>
  )

  target_link_libraries(
    ${target}
    PRIVATE
      $<BUILD_INTERFACE:PHP::sapi>
      $<$<PLATFORM_ID:Windows>:ws2_32;user32>
  )

  set_target_properties(
    ${target}
    PROPERTIES
      OUTPUT_NAME ${PHP_PROGRAM_PREFIX}phpdbg${PHP_PROGRAM_SUFFIX}
      ENABLE_EXPORTS TRUE # TODO: Check if there's a better solution.
      PHP_CLI TRUE
  )
endforeach()

if(MSVC)
  target_link_options(php_sapi_phpdbg PRIVATE /stack:8388608)
endif()

set_target_properties(
  php_sapi_phpdbg
  PROPERTIES
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}phpdbg${PHP_PROGRAM_SUFFIX}
)

if(TARGET php_sapi_phpdbg_shared)
  set_target_properties(
    php_sapi_phpdbg_shared
    PROPERTIES
      PREFIX lib
  )
endif()

################################################################################
# Readline support.
################################################################################

message(CHECK_START "Checking for readline support in phpdbg")

if(PHP_SAPI_PHPDBG_READLINE OR PHP_EXT_READLINE)
  message(CHECK_PASS "enabled")

  find_package(Editline)
  set_package_properties(
    Editline
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary for the phpdbg readline support."
  )

  target_link_libraries(php_sapi_phpdbg PRIVATE Editline::Editline)
  if(TARGET php_sapi_phpdbg_shared)
    target_link_libraries(php_sapi_phpdbg_shared PRIVATE Editline::Editline)
  endif()

  set(HAVE_LIBEDIT TRUE)
  set(HAVE_PHPDBG_READLINE TRUE)
else()
  message(CHECK_FAIL "disabled")
endif()

add_feature_info(
  "sapi/phpdbg readline"
  HAVE_PHPDBG_READLINE
  "enhanced command-line accessibility"
)

################################################################################
# Generate parser and lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)

################################################################################
# Configuration checks.
################################################################################

include(cmake/CheckTiocgwinsz.cmake)

message(
  CHECK_START
  "Checking for userfaultfd faulting on write-protected memory support"
)
check_symbol_exists(
  UFFDIO_WRITEPROTECT_MODE_WP
  linux/userfaultfd.h
  PHP_SAPI_PHPDBG_HAS_UFFDIO_WRITEPROTECT_MODE_WP
)
if(PHP_SAPI_PHPDBG_HAS_UFFDIO_WRITEPROTECT_MODE_WP)
  set(THREADS_PREFER_PTHREAD_FLAG TRUE)
  find_package(Threads)
  if(Threads_FOUND)
    target_link_libraries(php_sapi_phpdbg PRIVATE Threads::Threads)
    if(TARGET php_sapi_phpdbg_shared)
      target_link_libraries(php_sapi_phpdbg_shared PRIVATE Threads::Threads)
    endif()

    set(HAVE_USERFAULTFD_WRITEFAULT TRUE)
  else()
    message(WARNING "Threads are not available.")
  endif()
endif()
if(HAVE_USERFAULTFD_WRITEFAULT)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

################################################################################
# Installation.
################################################################################

install(
  TARGETS php_sapi_phpdbg
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Create log and run directories on installation.
php_install(CODE "
  file(
    MAKE_DIRECTORY
    \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_LOCALSTATEDIR}/log\"
    \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_RUNSTATEDIR}\"
  )
")

# Configure pkg-config phpdbg.pc metadata file and install shared phpdbg module.
if(TARGET php_sapi_phpdbg_shared)
  include(PHP/PkgConfig)
  php_pkgconfig_generate_pc(
    phpdbg.pc.in
    phpdbg.pc
    TARGET PHP::sapi::phpdbg_shared
    VARIABLES
      prefix "$<INSTALL_PREFIX>"
      exec_prefix "$<INSTALL_PREFIX>"
      includedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_INCLUDEDIR},$<INSTALL_PREFIX>>"
      php_include_prefix "${PHP_INCLUDE_PREFIX}"
      libdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LIBDIR},$<INSTALL_PREFIX>>"
      PHP_VERSION "${PHP_VERSION}"
      PHP_VERSION_ID "${PHP_VERSION_ID}"
      PHP_EXTENSION_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_EXTENSION_DIR},$<INSTALL_PREFIX>>"
      # TODO: Fix this for cmake --install ... --prefix
      PHP_CONFIG_FILE_SCAN_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_SCAN_DIR},$<INSTALL_PREFIX>>"
      PHP_CONFIG_FILE_PATH "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_PATH},$<INSTALL_PREFIX>>"
      PHP_DEBUG "$<IF:$<CONFIG:Debug,DebugAssertions>,yes,no>"
      PHP_THREAD_SAFETY "$<IF:$<BOOL:$<TARGET_PROPERTY:PHP::config,PHP_THREAD_SAFETY>>,yes,no>"
      PHP_PHPDBG_SAPI_NAME "$<GENEX_EVAL:$<TARGET_PROPERTY:php_sapi_phpdbg_shared,OUTPUT_NAME>>"
      PHP_API_VERSION "${PHP_API_VERSION}"
      PHP_ZEND_EXTENSION_API_NO "$<TARGET_PROPERTY:Zend::Zend,ZEND_EXTENSION_API_NO>"
      PHP_ZEND_MODULE_API_NO "$<TARGET_PROPERTY:Zend::Zend,ZEND_MODULE_API_NO>"
  )

  install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/phpdbg.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
  )

  install(
    TARGETS php_sapi_phpdbg_shared
    LIBRARY
      DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME
      DESTINATION ${CMAKE_INSTALL_LIBDIR}
  )
endif()

################################################################################
# Configure man documentation.
################################################################################

block()
  if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(program_prefix "${PHP_PROGRAM_PREFIX}")
    configure_file(phpdbg.1.in phpdbg.1 @ONLY)
    install(
      FILES ${CMAKE_CURRENT_BINARY_DIR}/phpdbg.1
      RENAME ${PHP_PROGRAM_PREFIX}phpdbg${PHP_PROGRAM_SUFFIX}.1
      DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
    )
  endif()
endblock()

################################################################################
# Configuration header.
################################################################################

configure_file(cmake/config.h.in config.h)
