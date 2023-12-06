include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckSymbolExists)

option(SAPI_CLI "Enable the CLI SAPI module" ON)

message(CHECK_START "Checking whether to build PHP CLI SAPI")
if(SAPI_CLI)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

if(NOT SAPI_CLI)
  return()
endif()

check_symbol_exists(setproctitle "unistd.h;stdlib.h" HAVE_SETPROCTITLE)
check_include_file(sys/pstat.h HAVE_SYS_PSTAT_H)

message(CHECK_START "Checking for PS_STRINGS")
check_c_source_compiles("
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

target_link_libraries(php_cli PRIVATE PHP::main)

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
  set_target_properties(php_cli PROPERTIES LINK_FLAGS "-undefined dynamic_lookup")
endif()

# TODO: Check if there's a better solution here.
set_target_properties(php_cli PROPERTIES ENABLE_EXPORTS TRUE)

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
