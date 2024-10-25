include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/Install)

################################################################################
# Configuration options.
################################################################################

option(SAPI_PHPDBG "Enable the phpdbg SAPI module" ON)

add_feature_info(
  "sapi/phpdbg"
  SAPI_PHPDBG
  "PHPDBG SAPI module"
)

cmake_dependent_option(
  SAPI_PHPDBG_SHARED
  "Build phpdbg SAPI as a shared module"
  OFF
  "SAPI_PHPDBG"
  OFF
)

cmake_dependent_option(
  SAPI_PHPDBG_DEBUG
  "Build phpdbg in debug mode to enable additional diagnostic output for\
  developing and troubleshooting phpdbg itself"
  OFF
  "SAPI_PHPDBG"
  OFF
)
mark_as_advanced(SAPI_PHPDBG_DEBUG)

cmake_dependent_option(
  SAPI_PHPDBG_READLINE
  "Explicitly enable readline support in phpdbg for command history accessible\
  through arrow keys. Requires the Editline library. If the PHP extension\
  'readline' is enabled during the build process, the phpdbg readline support\
  is automatically enabled regardless of this option."
  OFF
  "SAPI_PHPDBG"
  OFF
)
mark_as_advanced(SAPI_PHPDBG_READLINE)

message(CHECK_START "Checking phpdbg SAPI")
if(NOT SAPI_PHPDBG)
  message(CHECK_FAIL "disabled")
  return()
endif()
message(CHECK_PASS "enabled")

################################################################################
# Executable and library.
################################################################################

set(php_phpdbg_sources
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

add_executable(php_phpdbg ${php_phpdbg_sources})

target_compile_definitions(
  php_phpdbg
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<PLATFORM_ID:Windows>:YY_NO_UNISTD_H>
    $<$<BOOL:${SAPI_PHPDBG_DEBUG}>:PHPDBG_DEBUG=1>
)

target_link_libraries(
  php_phpdbg
  PRIVATE
    PHP::main
    Zend::Zend
    $<$<PLATFORM_ID:Windows>:ws2_32;user32>
)

target_link_options(
  php_phpdbg
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/stack:8388608>
)

set_target_properties(
  php_phpdbg
  PROPERTIES
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}phpdbg${PHP_PROGRAM_SUFFIX}
    # TODO: Check if there's a better solution here:
    ENABLE_EXPORTS TRUE
)

################################################################################
# Readline support.
################################################################################

message(CHECK_START "Checking for readline support in phpdbg")

if(SAPI_PHPDBG_READLINE OR EXT_READLINE)
  message(CHECK_PASS "enabled")

  find_package(Editline)
  set_package_properties(
    Editline
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary for the phpdbg readline support."
  )

  target_link_libraries(php_phpdbg PRIVATE Editline::Editline)

  set(HAVE_LIBEDIT 1 CACHE INTERNAL "Whether the libedit is available")

  set(
    HAVE_PHPDBG_READLINE 1
    CACHE INTERNAL "Whether phpdbg has readline support"
  )
else()
  message(CHECK_FAIL "disabled")
endif()

################################################################################
# The phpdbg shared library.
################################################################################

# TODO: Should readline extension be linked here like in the phpdbg executable?
if(SAPI_PHPDBG_SHARED)
  add_library(php_phpdbg_shared SHARED)

  set_target_properties(php_phpdbg_shared PROPERTIES OUTPUT_NAME phpdbg)

  target_sources(php_phpdbg_shared PRIVATE ${php_phpdbg_sources})

  target_compile_definitions(
    php_phpdbg_shared
    PRIVATE
      $<TARGET_PROPERTY:PHP::main,INTERFACE_COMPILE_DEFINITIONS>
      $<$<PLATFORM_ID:Windows>:YY_NO_UNISTD_H>
      $<$<BOOL:${SAPI_PHPDBG_DEBUG}>:PHPDBG_DEBUG=1>
  )

  target_include_directories(
    php_phpdbg_shared
    PRIVATE
      $<TARGET_PROPERTY:PHP::main,INTERFACE_INCLUDE_DIRECTORIES>
  )

  target_compile_options(
    php_phpdbg_shared
    PRIVATE $<TARGET_PROPERTY:PHP::main,INTERFACE_COMPILE_OPTIONS>
  )

  target_link_libraries(
    php_phpdbg_shared
    PRIVATE
      # TODO: fix this better in the future (building with -fPIC etc).
      PHP::main
      Zend::Zend
      $<$<PLATFORM_ID:Windows>:ws2_32;user32>
  )
endif()

################################################################################
# Generate lexers and parsers.
################################################################################

if(BISON_FOUND)
  bison_target(
    php_phpdbg_parser
    phpdbg_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
    COMPILE_FLAGS "${PHP_DEFAULT_BISON_FLAGS}"
    VERBOSE REPORT_FILE phpdbg_parser.output
    DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.h
  )

  add_custom_target(php_phpdbg_parser DEPENDS ${BISON_TARGET_outputs})
  add_dependencies(php_generate_files php_phpdbg_parser)
endif()

if(RE2C_FOUND)
  re2c_target(
    php_phpdbg_lexer
    phpdbg_lexer.l
    ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c
    OPTIONS -cbdF
  )
endif()

################################################################################
# Configuration checks.
################################################################################

include(PHP/CheckTiocgwinsz)

message(
  CHECK_START
  "Checking for userfaultfd faulting on write-protected memory support"
)
check_symbol_exists(
  UFFDIO_WRITEPROTECT_MODE_WP
  "linux/userfaultfd.h"
  HAVE_UFFDIO_WRITEPROTECT_MODE_WP
)
if(HAVE_UFFDIO_WRITEPROTECT_MODE_WP)
  if(NOT PHP_THREAD_SAFETY)
    set(THREADS_PREFER_PTHREAD_FLAG TRUE)
    find_package(Threads)
    if(Threads_FOUND)
      target_link_libraries(php_phpdbg PRIVATE Threads::Threads)
    else()
      message(WARNING "Threads not available.")
    endif()
  endif()

  if(PHP_THREAD_SAFETY OR Threads_FOUND)
    set(
      HAVE_USERFAULTFD_WRITEFAULT 1
      CACHE INTERNAL "Define to 1 if faulting on write-protected memory support\
 can be compiled for userfaultfd."
    )
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

# Man documentation.
block()
  set(program_prefix "${PHP_PROGRAM_PREFIX}")
  configure_file(phpdbg.1.in phpdbg.1 @ONLY)
endblock()

install(
  TARGETS php_phpdbg
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/phpdbg.1
  RENAME ${PHP_PROGRAM_PREFIX}phpdbg${PHP_PROGRAM_SUFFIX}.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

# Create log and run directories on installation.
php_install(CODE "
  file(
    MAKE_DIRECTORY
    \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_LOCALSTATEDIR}/log\"
    \"\$ENV{DESTDIR}\${CMAKE_INSTALL_FULL_RUNSTATEDIR}\"
  )
")
