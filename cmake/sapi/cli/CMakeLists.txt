include(CheckIncludeFile)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(SAPI_CLI "Enable the CLI SAPI module" ON)

message(CHECK_START "Checking whether to build cli SAPI")
if(SAPI_CLI)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

if(NOT SAPI_CLI)
  return()
endif()

cmake_dependent_option(
  SAPI_CLI_WIN_NO_CONSOLE
  "Build console-less CLI SAPI"
  OFF
  [[SAPI_CLI AND CMAKE_SYSTEM_NAME STREQUAL "Windows"]]
  OFF
)
add_feature_info("sapi/cli without console" SAPI_CLI_WIN_NO_CONSOLE
  "[Windows only] Same as CLI SAPI but without console (no output is given)."
)

check_symbol_exists(setproctitle "unistd.h;stdlib.h" HAVE_SETPROCTITLE)
check_include_file(sys/pstat.h HAVE_SYS_PSTAT_H)

message(CHECK_START "Checking for PS_STRINGS")
check_source_compiles(C "
  #include <machine/vmparam.h>
  #include <sys/exec.h>

  int main(void) {
    PS_STRINGS->ps_nargvstr = 1;
    PS_STRINGS->ps_argvstr = \"foo\";

    return 0;
  }
" HAVE_PS_STRINGS)
if(HAVE_PS_STRINGS)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

add_executable(php_cli
  php_cli_process_title.c
  php_cli_server.c
  php_cli.c
  php_http_parser.c
  ps_title.c
)

set_target_properties(php_cli PROPERTIES OUTPUT_NAME php)

target_compile_definitions(php_cli PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(
  php_cli
  PRIVATE
    PHP::main
    $<$<PLATFORM_ID:Windows>:ws2_32;shell32>
)

target_link_options(
  php_cli
  PRIVATE
    $<$<PLATFORM_ID:Windows>:/stack:67108864>
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  find_package(Editline)

  if(Editline_FOUND)
    target_link_libraries(php_cli PRIVATE Editline::Editline)
    target_compile_definitions(php_cli PRIVATE HAVE_LIBEDIT)
  endif()
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  set_target_properties(php_cli PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
endif()

# TODO: Check if there's a better solution here.
set_target_properties(php_cli PROPERTIES ENABLE_EXPORTS TRUE)

if(SAPI_CLI_WIN_NO_CONSOLE)
  add_executable(php_cli_win_no_console
    cli_win32.c
    php_cli_process_title.c
    ps_title.c
  )

  set_target_properties(php_cli_win_no_console PROPERTIES OUTPUT_NAME php-win)

  target_compile_definitions(php_cli_win_no_console PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

  target_link_options(php_cli_win_no_console PRIVATE /stack:67108864)

  target_link_libraries(php_cli_win_no_console PRIVATE shell32)
endif()

# Man documentation.
block()
  # TODO: Add @program_prefix@
  set(program_prefix "")
  configure_file(php.1.in php.1 @ONLY)
endblock()

target_sources(
  php_cli
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      cli.h
)

install(
  TARGETS php_cli
  RUNTIME
    DESTINATION "${CMAKE_INSTALL_BINDIR}"
  FILE_SET HEADERS
)

install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/php.1"
  DESTINATION "${CMAKE_INSTALL_MANDIR}/man1"
)
