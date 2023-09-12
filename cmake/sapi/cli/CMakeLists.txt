include(CheckCSourceCompiles)
include(CheckIncludeFile)

option(SAPI_CLI "Whether to use the PHP CLI SAPI module" ON)

if(NOT SAPI_CLI)
  return()
endif()

check_include_file(sys/pstat.h HAVE_SYS_PSTAT_H)
check_symbol_exists(setproctitle "unistd.h;stdlib.h" HAVE_SETPROCTITLE)

message(STATUS "Checking for PS_STRINGS")

if(NOT CMAKE_CROSSCOMPILING)
  check_c_source_runs("
    #include <machine/vmparam.h>
    #include <sys/exec.h>

    int main() {
      PS_STRINGS->ps_nargvstr = 1;
      PS_STRINGS->ps_argvstr = \"foo\";

      return 0;
    }
  " HAVE_PS_STRINGS)
endif()

add_executable(php
  php_cli.c
  php_http_parser.c
  php_cli_server.c
  ps_title.c
  php_cli_process_title.c
)

target_compile_definitions(php PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(php PRIVATE main)

if(EXTRA_LIBS)
  target_link_libraries(php PRIVATE ${EXTRA_LIBS})
endif()

if(EXTRA_DEFINITIONS)
  target_compile_definitions(php PRIVATE ${EXTRA_DEFINITIONS})
endif()

# TODO: Check if there's a better solution here.
set_target_properties(php PROPERTIES ENABLE_EXPORTS TRUE)
#target_compile_options(php PRIVATE -fvisibility=hidden)

# Man documentation.
configure_file(php.1.in php.1 @ONLY)

install(TARGETS php RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

target_sources(
  php
  PUBLIC FILE_SET sapi_php_headers
  TYPE HEADERS
  FILES cli.h
)

install(
  TARGETS php
  FILE_SET sapi_php_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/sapi/php
)

install(
  FILES
    php.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)
