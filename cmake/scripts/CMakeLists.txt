block(SCOPE_FOR VARIABLES)
  # Man documentation.
  message(STATUS "Creating scripts/man1/php-config.1")
  configure_file(man1/php-config.1.in man1/php-config.1 @ONLY)

  message(STATUS "Creating scripts/man1/phpize.1")
  configure_file(man1/phpize.1.in man1/phpize.1 @ONLY)

  # The php-config script.
  set(EXPANDED_PHP_CONFIG_FILE_PATH "${PHP_CONFIG_FILE_PATH}")
  set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}")
  message(STATUS "Creating scripts/php-config")
  configure_file(php-config.in php-config @ONLY)
endblock()

install(
  FILES
    "${PROJECT_BINARY_DIR}/scripts/man1/php-config.1"
    "${PROJECT_BINARY_DIR}/scripts/man1/phpize.1"
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

install(
  FILES
    "${PROJECT_BINARY_DIR}/scripts/php-config"
  DESTINATION ${CMAKE_INSTALL_BINDIR}
)
