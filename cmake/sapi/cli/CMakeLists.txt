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

  if(HAVE_PS_STRINGS)
    message(STATUS "PS_STRINGS found")
    set(HAVE_PS_STRINGS 1 CACHE STRING "Define to 1 if the PS_STRINGS thing exists.")
  else()
    message(STATUS "PS_STRINGS not present")
  endif()

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

  # TODO: PHP_EXTENSIONS here is not defined yet because we include extensions
  # after SAPI modules. Refactor this better.
  # foreach(item IN LISTS PHP_EXTENSIONS)
  #   message(STATUS "Linking ${item}")
  #   target_link_libraries(php PUBLIC ext_${item})
  # endforeach()

  target_link_libraries(php PUBLIC ext_bcmath)
  if(calendar)
    target_link_libraries(php PUBLIC ext_calendar)
  endif()
  target_link_libraries(php PUBLIC ext_ctype)
  target_link_libraries(php PUBLIC ext_date)
  if(exif)
    target_link_libraries(php PUBLIC ext_exif)
  endif()
  target_link_libraries(php PUBLIC ext_hash)
  target_link_libraries(php PUBLIC ext_fileinfo)
  target_link_libraries(php PUBLIC ext_filter)
  target_link_libraries(php PUBLIC ext_json)
  target_link_libraries(php PUBLIC ext_pcre)
  target_link_libraries(php PUBLIC ext_phar)
  if(posix)
    target_link_libraries(php PUBLIC ext_posix)
  endif()
  target_link_libraries(php PUBLIC ext_random)
  target_link_libraries(php PUBLIC ext_reflection)
  target_link_libraries(php PUBLIC ext_spl)
  target_link_libraries(php PUBLIC ext_standard)

  if(EXTRA_LIBS)
    target_link_libraries(php PUBLIC ${EXTRA_LIBS})
  endif()

  set_target_properties(php PROPERTIES PUBLIC_HEADER "sapi/cli/cli.h")
endif()
