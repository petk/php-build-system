include(PHP/ConfigureFile)

# Man documentation.
block()
  set(program_prefix "${PHP_PROGRAM_PREFIX}")

  message(STATUS "Creating scripts/man1/php-config.1")
  configure_file(man1/php-config.1.in man1/php-config.1 @ONLY)

  message(STATUS "Creating scripts/man1/phpize.1")
  configure_file(man1/phpize.1.in man1/phpize.1 @ONLY)
endblock()

install(
  FILES
    ${PROJECT_BINARY_DIR}/scripts/man1/php-config.1
    ${PROJECT_BINARY_DIR}/scripts/man1/phpize.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

block()
  find_program(
    SED_EXECUTABLE
    NAMES
      sed  # Default name available on most *nix systems
      gsed # Brew gnu-sed package
    DOC "Path to the stream editor (sed) for filtering and transforming text"
  )
  mark_as_advanced(SED_EXECUTABLE)
  if(SED_EXECUTABLE)
    set(SED "${SED_EXECUTABLE}")
  else()
    message(WARNING "sed not found, setting default to /usr/bin/sed")
    set(SED /usr/bin/sed)
  endif()

  # The php-config script.
  message(STATUS "Creating scripts/php-config")
  php_configure_file(
    php-config.in
    php-config
    INSTALL_DESTINATION ${CMAKE_INSTALL_BINDIR}
    VARIABLES
      SED "${SED}"
      prefix "$<INSTALL_PREFIX>"
      datarootdir "$<INSTALL_PREFIX>/${CMAKE_INSTALL_DATAROOTDIR}"
      exec_prefix "$<INSTALL_PREFIX>"
      PHP_VERSION "${PHP_VERSION}"
      PHP_VERSION_ID "${PHP_VERSION_ID}"
      include_dir "$<INSTALL_PREFIX>/${CMAKE_INSTALL_INCLUDEDIR}"
      # TODO:
      PHP_LDFLAGS ""
      # TODO:
      EXTRA_LIBS ""
      EXTENSION_DIR "${PHP_EXTENSION_DIR}"
      mandir "$<INSTALL_PREFIX>/${CMAKE_INSTALL_MANDIR}"
      program_prefix "${PHP_PROGRAM_PREFIX}"
      program_suffix "${PHP_PROGRAM_SUFFIX}"
      EXEEXT "${CMAKE_EXECUTABLE_SUFFIX}"
      # TODO:
      CONFIGURE_OPTIONS ""
      # TODO:
      PHP_INSTALLED_SAPIS ""
      EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}"
      EXPANDED_PHP_CONFIG_FILE_PATH "${PHP_CONFIG_FILE_PATH}"
      bindir "$<INSTALL_PREFIX>/${CMAKE_INSTALL_BINDIR}"
  )

  # The phpize script.
  message(STATUS "Creating scripts/phpize")
  php_configure_file(
    phpize.in
    phpize
    INSTALL_DESTINATION ${CMAKE_INSTALL_BINDIR}
    VARIABLES
      prefix "$<INSTALL_PREFIX>"
      datarootdir "$<INSTALL_PREFIX>/${CMAKE_INSTALL_DATAROOTDIR}"
      exec_prefix "$<INSTALL_PREFIX>"
      libdir "$<INSTALL_PREFIX>/${CMAKE_INSTALL_LIBDIR}"
      includedir "$<INSTALL_PREFIX>/${CMAKE_INSTALL_INCLUDEDIR}"
      SED "${SED}"
  )
endblock()

# Configure pkgconf php.pc metadata file.
include(PHP/PkgConfigGenerator)
pkgconfig_generate_pc(
  php.pc.in
  php.pc
  TARGET php_cli
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
  VARIABLES
    prefix "$<INSTALL_PREFIX>"
    exec_prefix "$<INSTALL_PREFIX>"
    includedir "$<INSTALL_PREFIX>/${CMAKE_INSTALL_INCLUDEDIR}"
    libdir "$<INSTALL_PREFIX>/${CMAKE_INSTALL_LIBDIR}"
    PHP_VERSION "${PHP_VERSION}"
    PHP_VERSION_ID "${PHP_VERSION_ID}"
    PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}"
    PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}"
    PHP_CONFIG_FILE_PATH "${PHP_CONFIG_FILE_PATH}"
    PHP_DEBUG:BOOL "${PHP_DEBUG}"
    PHP_THREAD_SAFETY:BOOL "${PHP_THREAD_SAFETY}"
)
