#[=============================================================================[
# The cli SAPI

## Configuration options

### PHP_SAPI_CLI

* Default: `ON`
* Values: `ON|OFF`

Enables the PHP CLI (Command-Line Interpreter/Interface) SAPI executable module.

### PHP_SAPI_CLI_WIN_NO_CONSOLE

* Default: `OFF`
* Values: `ON|OFF`

Builds additional console-less CLI SAPI executable (executable name `php-win`).
Same as the main CLI SAPI (`php`) but without the console (no output is given).

> [!NOTE]
> This option is only available when the target system is Windows.
#]=============================================================================]

include(CheckIncludeFiles)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
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

check_symbol_exists(setproctitle "unistd.h;stdlib.h" PHP_SAPI_HAVE_SETPROCTITLE)
set(HAVE_SETPROCTITLE ${PHP_SAPI_HAVE_SETPROCTITLE})

check_include_files(sys/pstat.h PHP_SAPI_CLI_HAVE_SYS_PSTAT_H)
set(HAVE_SYS_PSTAT_H ${PHP_SAPI_CLI_HAVE_SYS_PSTAT_H})

# For some BSD-based systems.
message(CHECK_START "Checking for PS_STRINGS")
cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  check_source_compiles(C [[
    #include <machine/vmparam.h> // For old BSD.
    #include <sys/exec.h>

    int main(void)
    {
      PS_STRINGS->ps_nargvstr = 1;
      PS_STRINGS->ps_argvstr = "foo";

      return 0;
    }
  ]] PHP_SAPI_CLI_HAVE_PS_STRINGS)
cmake_pop_check_state()
if(PHP_SAPI_CLI_HAVE_PS_STRINGS)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
set(HAVE_PS_STRINGS ${PHP_SAPI_CLI_HAVE_PS_STRINGS})

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

if(MSVC)
  target_link_options(php_sapi_cli PRIVATE /stack:67108864)
endif()

set_target_properties(
  php_sapi_cli
  PROPERTIES
    EXPORT_NAME Interpreter
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}php${PHP_PROGRAM_SUFFIX}
    PHP_CLI TRUE
)

# Link editline library conditionally based on readline extension.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  set(type "")
  if(PHP_EXT_READLINE)
    get_target_property(type PHP::ext::readline TYPE)
  endif()

  if(NOT PHP_EXT_READLINE OR NOT type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    find_package(Editline)
    if(Editline_FOUND)
      target_link_libraries(php_sapi_cli PRIVATE Editline::Editline)
      set(HAVE_LIBEDIT TRUE)
    endif()
  endif()
endif()

install(
  TARGETS
    php_sapi_cli
  EXPORT php_sapi_cli_export
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT php-sapi-cli
  FILE_SET HEADERS
    DESTINATION ${PHP_INSTALL_INCLUDEDIR}/sapi/cli
    COMPONENT php-development
)

install(
  EXPORT php_sapi_cli_export
  NAMESPACE PHP::
  FILE PHPInterpreterTargets.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/PHP/targets
  COMPONENT php-development
)

################################################################################
# Provide command to generate sapi/cli/mime_type_map.h manually with:
# cmake --build <build-dir> -t php_sapi_cli_generate_mime_type_map
################################################################################

include(PHP/AddCommand)

php_add_command(
  php_sapi_cli_generate_mime_type_map
  PHP_COMMAND
    ${CMAKE_CURRENT_SOURCE_DIR}/generate_mime_type_map.php
    > ${CMAKE_CURRENT_SOURCE_DIR}/mime_type_map.h
  PHP_EXTENSIONS openssl
  COMMENT "[sapi/cli] Regenerating mime_type_map.h"
  VERBATIM
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
      EXPORT_NAME Sapi::CliNoConsole
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

  if(MSVC)
    target_link_options(php_sapi_cli_win PRIVATE /stack:67108864)
  endif()

  install(
    TARGETS php_sapi_cli_win
    EXPORT php_sapi_cli_export
    RUNTIME
      DESTINATION ${CMAKE_INSTALL_BINDIR}
      COMPONENT php-sapi-cli
  )
endif()

################################################################################
# Configure man documentation.
################################################################################

block()
  if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(program_prefix "${PHP_PROGRAM_PREFIX}")
    configure_file(php.1.in php.1 @ONLY)
    install(
      FILES ${CMAKE_CURRENT_BINARY_DIR}/php.1
      RENAME ${PHP_PROGRAM_PREFIX}php${PHP_PROGRAM_SUFFIX}.1
      DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
      COMPONENT php-doc
    )
  endif()
endblock()

################################################################################
# Configuration header.
################################################################################

configure_file(cmake/config.h.in config.h)
