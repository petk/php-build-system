include(CheckCSourceCompiles)
include(CMakeDependentOption)

option(SAPI_PHPDBG "Whether to use the PHP PHPDBG SAPI module" ON)

# TODO: Check if this can be simplified and removed in favor of the PHP_DEBUG option.
cmake_dependent_option(
  SAPI_PHPDBG_DEBUG
  "Whether to build phpdbg in debug mode"
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
  phpdbg.c
  phpdbg_parser.c
  phpdbg_lexer.c
  phpdbg_prompt.c
  phpdbg_help.c
  phpdbg_break.c
  phpdbg_print.c
  phpdbg_bp.c
  phpdbg_list.c
  phpdbg_utils.c
  phpdbg_info.c
  phpdbg_cmd.c
  phpdbg_set.c
  phpdbg_frame.c
  phpdbg_watch.c
  phpdbg_btree.c
  phpdbg_sigsafe.c
  phpdbg_io.c
  phpdbg_out.c
)

set_target_properties(php_phpdbg PROPERTIES OUTPUT_NAME phpdbg)

if(BISON_FOUND)
  bison_target(php_phpdbg_parser phpdbg_parser.y ${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_parser.c
    COMPILE_FLAGS "-v -d"
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

target_compile_definitions(
  php_phpdbg
  PRIVATE
    _GNU_SOURCE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

target_link_libraries(php_phpdbg PRIVATE PHP::main)

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  set_target_properties(php_phpdbg PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
endif()

message(STATUS "Checking for userfaultfd faulting on write-protected memory support")
check_c_source_compiles("
  #include <linux/userfaultfd.h>
  #ifndef UFFDIO_WRITEPROTECT_MODE_WP
  # error userfaults on write-protected memory not supported
  #endif
" HAVE_USERFAULTFD_WRITEFAULT)

set_target_properties(php_phpdbg PROPERTIES ENABLE_EXPORTS TRUE)

set(HAVE_PHPDBG 1 CACHE INTERNAL "")

# Man documentation.
configure_file(phpdbg.1.in phpdbg.1 @ONLY)

install(TARGETS php_phpdbg DESTINATION ${CMAKE_INSTALL_BINDIR})

install(
  FILES
    phpdbg.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)
