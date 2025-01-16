#[=============================================================================[
# The cli SAPI

Configure the `cli` PHP SAPI.

## PHP_SAPI_CLI

* Default: `ON`
* Values: `ON|OFF`

Enable the PHP CLI (Command-Line Interpreter/Interface) SAPI executable module.

## PHP_SAPI_CLI_WIN_NO_CONSOLE

* Default: `OFF`
* Values: `ON|OFF`

Build additional console-less CLI SAPI executable (executable name `php-win`).
Same as the main CLI SAPI (`php`) but without the console (no output is given).

> [!NOTE]
> This option is only available when the target system is Windows.
#]=============================================================================]

include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_SAPI_CLI "Enable the CLI SAPI module" ON)
add_feature_info(
  "sapi/cli"
  PHP_SAPI_CLI
  "Command-Line Interpreter/Interface executable"
)

cmake_dependent_option(
  PHP_SAPI_CLI_WIN_NO_CONSOLE
  "Build additional CLI SAPI without console (no output is given)"
  OFF
  [[PHP_SAPI_CLI AND CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
add_feature_info(
  "sapi/cli console-less"
  PHP_SAPI_CLI_WIN_NO_CONSOLE
  "additional executable without console output"
)

if(NOT PHP_SAPI_CLI)
  return()
endif()

################################################################################
# Configuration checks.
################################################################################

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

################################################################################
# The cli SAPI.
################################################################################

add_executable(php_sapi_cli)
add_executable(PHP::sapi::cli ALIAS php_sapi_cli)

target_sources(
  php_sapi_cli
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
  php_sapi_cli
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

target_link_libraries(
  php_sapi_cli
  PRIVATE
    $<BUILD_INTERFACE:PHP::sapi>
    $<$<PLATFORM_ID:Windows>:ws2_32;shell32>
)

target_link_options(
  php_sapi_cli
  PRIVATE
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/stack:67108864>
)

set_target_properties(
  php_sapi_cli
  PROPERTIES
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}php${PHP_PROGRAM_SUFFIX}
    ENABLE_EXPORTS TRUE # TODO: Check if there's a better solution.
    PHP_CLI TRUE
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  # Link readline extension interface library if enabled and built statically.
  target_link_libraries(
    php_sapi_cli
    PRIVATE
      $<$<AND:$<TARGET_EXISTS:PHP::ext::readline>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:PHP::ext::readline,TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:$<TARGET_PROPERTY:PHP::ext::readline,IMPORTED_LINK_INTERFACE_LIBRARIES>>
  )
endif()

# Man documentation.
block()
  set(program_prefix "${PHP_PROGRAM_PREFIX}")
  configure_file(php.1.in php.1 @ONLY)
endblock()

install(
  TARGETS php_sapi_cli
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

################################################################################
# The cli SAPI without console on Windows.
################################################################################

if(PHP_SAPI_CLI_WIN_NO_CONSOLE)
  add_executable(php_sapi_cli_win)
  add_executable(PHP::sapi::cli_win ALIAS php_sapi_cli_win)

  target_sources(
    php_sapi_cli_win
    PRIVATE
      cli_win32.c
      php_cli_process_title.c
      php_cli_process_title.stub.php
      ps_title.c
  )

  set_target_properties(
    php_sapi_cli_win
    PROPERTIES
      OUTPUT_NAME ${PHP_PROGRAM_PREFIX}php-win${PHP_PROGRAM_SUFFIX}
  )

  target_compile_definitions(
    php_sapi_cli_win
    PRIVATE
      ZEND_ENABLE_STATIC_TSRMLS_CACHE
  )

  target_link_libraries(
    php_sapi_cli_win
    PRIVATE
      $<BUILD_INTERFACE:PHP::sapi>
      shell32
  )

  target_link_options(
    php_sapi_cli_win
    PRIVATE
      /stack:67108864
  )
endif()

configure_file(cmake/config.h.in config.h)
