#[=============================================================================[
# The cli SAPI

Configure the `cli` PHP SAPI.

## SAPI_CLI

* Default: `ON`
* Values: `ON|OFF`

Enable the PHP CLI (Command-Line Interpreter/Interface) SAPI executable module.

## SAPI_CLI_WIN_NO_CONSOLE

* Default: `OFF`
* Values: `ON|OFF`

Build console-less CLI SAPI. Same as the main CLI SAPI but without console (no
output is given).

> [!NOTE]
> This option is only available when the target system is Windows.
#]=============================================================================]

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(SAPI_CLI "Enable the CLI SAPI module" ON)
add_feature_info(
  "sapi/cli"
  SAPI_CLI
  "Command-Line Interpreter/Interface executable"
)

cmake_dependent_option(
  SAPI_CLI_WIN_NO_CONSOLE
  "Build console-less CLI SAPI"
  OFF
  [[SAPI_CLI AND CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
add_feature_info(
  "sapi/cli without console"
  SAPI_CLI_WIN_NO_CONSOLE
  "CLI SAPI without console (no output is given)"
)

if(NOT SAPI_CLI)
  return()
endif()

check_symbol_exists(setproctitle "unistd.h;stdlib.h" HAVE_SETPROCTITLE)
check_include_file(sys/pstat.h HAVE_SYS_PSTAT_H)

message(CHECK_START "Checking for PS_STRINGS")
check_source_compiles(C [[
  #include <machine/vmparam.h>
  #include <sys/exec.h>

  int main(void)
  {
    PS_STRINGS->ps_nargvstr = 1;
    PS_STRINGS->ps_argvstr = "foo";

    return 0;
  }
]] HAVE_PS_STRINGS)
if(HAVE_PS_STRINGS)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

add_executable(php_cli)
add_executable(PHP::cli ALIAS php_cli)

target_sources(
  php_cli
  PRIVATE
    php_cli_process_title.c
    php_cli_process_title.stub.php
    php_cli_server.c
    php_cli_server.stub.php
    php_cli.c
    php_http_parser.c
    ps_title.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        cli.h
)

target_compile_definitions(
  php_cli
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

target_link_libraries(
  php_cli
  PRIVATE
    PHP::PHP
    $<$<PLATFORM_ID:Windows>:ws2_32;shell32>
)

target_link_options(
  php_cli
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/stack:67108864>
)

set_target_properties(
  php_cli
  PROPERTIES
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}php${PHP_PROGRAM_SUFFIX}
    # TODO: Check if there's a better solution here:
    ENABLE_EXPORTS TRUE
    PHP_SAPI_CLI TRUE
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # Link readline extension interface library if enabled and built statically.
  target_link_libraries(
    php_cli
    PRIVATE
      $<$<AND:$<TARGET_EXISTS:php_readline>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:php_readline,TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:$<TARGET_PROPERTY:php_readline,IMPORTED_LINK_INTERFACE_LIBRARIES>>
  )
endif()

if(SAPI_CLI_WIN_NO_CONSOLE)
  add_executable(php_cli_win_no_console)
  add_executable(PHP::cli_win_no_console ALIAS php_cli_win_no_console)

  target_sources(
    php_cli_win_no_console
    PRIVATE
      cli_win32.c
      php_cli_process_title.c
      php_cli_process_title.stub.php
      ps_title.c
  )

  set_target_properties(
    php_cli_win_no_console
    PROPERTIES
      OUTPUT_NAME ${PHP_PROGRAM_PREFIX}php-win${PHP_PROGRAM_SUFFIX}
  )

  target_compile_definitions(
    php_cli_win_no_console
    PRIVATE
      ZEND_ENABLE_STATIC_TSRMLS_CACHE
  )

  target_link_libraries(
    php_cli_win_no_console
    PRIVATE
      PHP::PHP
      shell32
  )

  target_link_options(
    php_cli_win_no_console
    PRIVATE
      /stack:67108864
  )
endif()

# Man documentation.
block()
  set(program_prefix "${PHP_PROGRAM_PREFIX}")
  configure_file(php.1.in php.1 @ONLY)
endblock()

install(
  TARGETS php_cli
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/sapi/cli
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/php.1
  RENAME ${PHP_PROGRAM_PREFIX}php${PHP_PROGRAM_SUFFIX}.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

configure_file(config.cmake.h.in config.h)
