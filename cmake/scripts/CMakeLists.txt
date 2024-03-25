block()
  find_program(SED sed)
  # TODO: Add program_prefix.
  set(program_prefix "")
  set(prefix "${CMAKE_INSTALL_PREFIX}")
  set(exec_prefix "${CMAKE_INSTALL_PREFIX}")
  set(includedir "${CMAKE_INSTALL_FULL_INCLUDEDIR}")

  # TODO: Sync this with the PHP_LAYOUT.
  set(datarootdir ${CMAKE_INSTALL_FULL_DATADIR})
  # TODO: Add PHP_LDFLAGS.
  set(PHP_LDFLAGS "")
  # TODO: Add EXTRA_LIBS.
  set(EXTRA_LIBS "")
  set(EXTENSION_DIR "${PHP_EXTENSION_DIR}")
  set(mandir "${CMAKE_INSTALL_FULL_MANDIR}")
  # TODO: Add program_sufix.
  set(program_suffix "")
  set(EXEEXT "${CMAKE_EXECUTABLE_SUFFIX}")
  # TODO: Add CONFIGURE_OPTIONS.
  set(CONFIGURE_OPTIONS "")
  # TODO: Add PHP_INSTALLED_SAPIS.
  set(PHP_INSTALLED_SAPIS "")
  set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}")
  set(EXPANDED_PHP_CONFIG_FILE_PATH "${PHP_CONFIG_FILE_PATH}")
  set(bindir "${CMAKE_INSTALL_FULL_BINDIR}")

  # Man documentation.
  message(STATUS "Creating scripts/man1/php-config.1")
  configure_file(man1/php-config.1.in man1/php-config.1 @ONLY)
  message(STATUS "Creating scripts/man1/phpize.1")
  configure_file(man1/phpize.1.in man1/phpize.1 @ONLY)

  # The php-config script.
  message(STATUS "Creating scripts/php-config")
  configure_file(php-config.in php-config @ONLY)

  # The phpize script.
  message(STATUS "Creating scripts/phpize")
  configure_file(phpize.in phpize @ONLY)
endblock()

# Configure pkgconf php.pc metadata file.
block()
  set(prefix "${CMAKE_INSTALL_PREFIX}")
  set(includedir "${CMAKE_INSTALL_FULL_INCLUDEDIR}")
  set(libdir "${CMAKE_INSTALL_LIBDIR}")
  set(exec_prefix "${CMAKE_INSTALL_PREFIX}")
  configure_file(php.pc.in php.pc @ONLY)
endblock()

install(
  FILES
    ${PROJECT_BINARY_DIR}/scripts/man1/php-config.1
    ${PROJECT_BINARY_DIR}/scripts/man1/phpize.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/php-config
    ${CMAKE_CURRENT_BINARY_DIR}/phpize
  DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/php.pc
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
