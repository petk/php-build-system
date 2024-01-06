include(CheckSourceCompiles)
include(CMakeDependentOption)

option(SAPI_PHPDBG "Enable the phpdbg SAPI module" ON)

message(CHECK_START "Checking whether to build phpdbg SAPI")
if(SAPI_PHPDBG)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

# TODO: Check if this can be simplified in favor of the CMake's Debug build type.
cmake_dependent_option(
  SAPI_PHPDBG_DEBUG
  "Build phpdbg SAPI in debug mode"
  OFF
  "SAPI_PHPDBG"
  OFF
)

# TODO: Check if this can be simplified and removed in favor of the readline option.
cmake_dependent_option(
  SAPI_PHPDBG_READLINE
  "Enable readline support in phpdbg (depends on static ext/readline)"
  OFF
  "SAPI_PHPDBG"
  OFF
)

if(NOT SAPI_PHPDBG)
  return()
endif()

add_executable(php_phpdbg
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
  phpdbg_prompt.c
  phpdbg_set.c
  phpdbg_sigsafe.c
  phpdbg_utils.c
  phpdbg_watch.c
  $<$<PLATFORM_ID:Windows>:phpdbg_win.c>
  phpdbg.c
)

set_target_properties(php_phpdbg PROPERTIES OUTPUT_NAME phpdbg)

target_compile_definitions(
  php_phpdbg
  PRIVATE
    _GNU_SOURCE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

target_link_libraries(php_phpdbg PRIVATE PHP::main)

if(BISON_FOUND)
  bison_target(
    php_phpdbg_parser
    phpdbg_parser.y
    ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
    COMPILE_FLAGS "-Wall -v -d"
    DEFINES_FILE ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.h
  )
endif()

if(RE2C_FOUND)
  re2c_target(
    NAME php_phpdbg_lexer
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.l"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c"
    OPTIONS "--no-generation-date -cbdF"
  )
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  set_target_properties(php_phpdbg PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
endif()

include(PHP/CheckTiocgwinsz)

if(SAPI_PHPDBG_DEBUG)
  set(PHPDBG_DEBUG 1 CACHE INTERNAL "Whether phpdbg debugging is enabled")
else()
  set(PHPDBG_DEBUG 0 CACHE INTERNAL "Whether phpdbg debugging is enabled")
endif()

message(CHECK_START "Checking for userfaultfd faulting on write-protected memory support")
check_source_compiles(C "
  #include <linux/userfaultfd.h>
  #ifndef UFFDIO_WRITEPROTECT_MODE_WP
  # error userfaults on write-protected memory not supported
  #endif
" _HAVE_USERFAULTFD_WRITEFAULT)
if(_HAVE_USERFAULTFD_WRITEFAULT)
  if(PHP_THREAD_SAFETY)
    set(
      HAVE_USERFAULTFD_WRITEFAULT 1
      CACHE INTERNAL "Whether faulting on write-protected memory support can \
be compiled for userfaultfd"
    )
    message(CHECK_PASS "yes")
  else()
    # TODO: Add threads flags check here and set the variable accordingly.
    message(CHECK_PASS "no")
  endif()
else()
  message(CHECK_FAIL "no")
endif()

set_target_properties(php_phpdbg PROPERTIES ENABLE_EXPORTS TRUE)

set(HAVE_PHPDBG 1 CACHE INTERNAL "Whether the phpdbg SAPI is enabled")

# Man documentation.
block()
  # TODO: Add @program_prefix@
  set(program_prefix "")
  configure_file(phpdbg.1.in phpdbg.1 @ONLY)
endblock()

# TODO: Add prefix and suffix to installed executable file.
install(
  TARGETS php_phpdbg
  RUNTIME
    DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

# TODO: Add prefix and suffix to installed man documentation file.
install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/phpdbg.1"
  DESTINATION "${CMAKE_INSTALL_MANDIR}/man1"
)

# Create log and run directories on installation.
install(DIRECTORY DESTINATION ${CMAKE_INSTALL_LOCALSTATEDIR}/log)
install(DIRECTORY DESTINATION ${CMAKE_INSTALL_LOCALSTATEDIR}/run)
