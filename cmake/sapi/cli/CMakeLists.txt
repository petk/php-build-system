include(CheckCSourceCompiles)

option(cli "Whether to use the PHP CLI SAPI module" ON)

if(cli)
  check_include_file(sys/pstat.h HAVE_SYS_PSTAT_H)
  check_symbol_exists(setproctitle "unistd.h;stdlib.h" HAVE_SETPROCTITLE)

  message(STATUS "Checking for PS_STRINGS")

  check_c_source_runs("
  #include <machine/vmparam.h>
  #include <sys/exec.h>

  int main() {
    PS_STRINGS->ps_nargvstr = 1;
    PS_STRINGS->ps_argvstr = \"foo\";

    return 0;
  }
  " HAVE_PS_STRINGS)

  add_executable(php
    php_cli.c
    php_http_parser.c
    php_cli_server.c
    ps_title.c
    php_cli_process_title.c
  )

  target_include_directories(
    php
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  )

  target_link_libraries(php PUBLIC main)
  target_link_libraries(php PUBLIC TSRM)
  target_link_libraries(php PUBLIC Zend)

  foreach(item IN LISTS PHP_EXTENSIONS)
    message(STATUS "Linking ${item}")
    target_link_libraries(php PUBLIC ext_${item})
  endforeach()

  if(EXTRA_LIBS)
    target_link_libraries(php PUBLIC ${EXTRA_LIBS})
  endif()

  set_target_properties(php PROPERTIES PUBLIC_HEADER "sapi/cli/cli.h")
endif()
