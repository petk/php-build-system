include(PHP/ConfigureFile)

# Man documentation.
block()
  set(program_prefix "${PHP_PROGRAM_PREFIX}")

  message(STATUS "Creating scripts/man1/php-config.1")
  configure_file(man1/php-config.1.in man1/php-config.1 @ONLY)
  install(
    FILES ${PROJECT_BINARY_DIR}/scripts/man1/php-config.1
    RENAME ${PHP_PROGRAM_PREFIX}php-config${PHP_PROGRAM_SUFFIX}.1
    DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
  )

  message(STATUS "Creating scripts/man1/phpize.1")
  configure_file(man1/phpize.1.in man1/phpize.1 @ONLY)
  install(
    FILES ${PROJECT_BINARY_DIR}/scripts/man1/phpize.1
    RENAME ${PHP_PROGRAM_PREFIX}phpize${PHP_PROGRAM_SUFFIX}.1
    DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
  )
endblock()

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
    VARIABLES
      SED "${SED}"
      prefix "$<INSTALL_PREFIX>"
      datarootdir "$<PHP_EXPAND:${CMAKE_INSTALL_DATAROOTDIR}>"
      exec_prefix "$<INSTALL_PREFIX>"
      PHP_VERSION "${PHP_VERSION}"
      PHP_VERSION_ID "${PHP_VERSION_ID}"
      include_dir "$<PHP_EXPAND:${CMAKE_INSTALL_INCLUDEDIR}>"
      # TODO:
      PHP_LDFLAGS ""
      # TODO:
      EXTRA_LIBS ""
      EXTENSION_DIR "$<PHP_EXPAND:${PHP_EXTENSION_DIR}>"
      mandir "$<PHP_EXPAND:${CMAKE_INSTALL_MANDIR}>"
      program_prefix "${PHP_PROGRAM_PREFIX}"
      program_suffix "${PHP_PROGRAM_SUFFIX}"
      EXEEXT "${CMAKE_EXECUTABLE_SUFFIX}"
      # TODO:
      CONFIGURE_OPTIONS ""
      # TODO:
      PHP_INSTALLED_SAPIS ""
      EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "$<PHP_EXPAND:${PHP_CONFIG_FILE_SCAN_DIR}>"
      EXPANDED_PHP_CONFIG_FILE_PATH "$<PHP_EXPAND:${PHP_CONFIG_FILE_PATH}>"
      bindir "$<PHP_EXPAND:${CMAKE_INSTALL_BINDIR}>"
  )

  install(
    PROGRAMS
    ${CMAKE_CURRENT_BINARY_DIR}/php-config
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME ${PHP_PROGRAM_PREFIX}php-config${PHP_PROGRAM_SUFFIX}
  )

  # The phpize script.
  message(STATUS "Creating scripts/phpize")
  php_configure_file(
    phpize.in
    phpize
    VARIABLES
      prefix "$<INSTALL_PREFIX>"
      datarootdir "$<PHP_EXPAND:${CMAKE_INSTALL_DATAROOTDIR}>"
      exec_prefix "$<INSTALL_PREFIX>"
      libdir "$<PHP_EXPAND:${CMAKE_INSTALL_LIBDIR}>"
      includedir "$<PHP_EXPAND:${CMAKE_INSTALL_INCLUDEDIR}>"
      SED "${SED}"
  )

  install(
    PROGRAMS
    ${CMAKE_CURRENT_BINARY_DIR}/phpize
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME ${PHP_PROGRAM_PREFIX}phpize${PHP_PROGRAM_SUFFIX}
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
    includedir "$<PHP_EXPAND:${CMAKE_INSTALL_INCLUDEDIR}>"
    libdir "$<PHP_EXPAND:${CMAKE_INSTALL_LIBDIR}>"
    PHP_VERSION "${PHP_VERSION}"
    PHP_VERSION_ID "${PHP_VERSION_ID}"
    PHP_EXTENSION_DIR "$<PHP_EXPAND:${PHP_EXTENSION_DIR}>"
    PHP_CONFIG_FILE_SCAN_DIR "$<PHP_EXPAND:${PHP_CONFIG_FILE_SCAN_DIR}>"
    PHP_CONFIG_FILE_PATH "$<PHP_EXPAND:${PHP_CONFIG_FILE_PATH}>"
    PHP_DEBUG:BOOL "${PHP_DEBUG}"
    PHP_THREAD_SAFETY:BOOL "${PHP_THREAD_SAFETY}"
)

# Install Autotools build files.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  install(
    FILES
      ${PHP_SOURCE_DIR}/build/ax_check_compile_flag.m4
      ${PHP_SOURCE_DIR}/build/ax_gcc_func_attribute.m4
      ${PHP_SOURCE_DIR}/build/gen_stub.php
      ${PHP_SOURCE_DIR}/build/libtool.m4
      ${PHP_SOURCE_DIR}/build/ltmain.sh
      ${PHP_SOURCE_DIR}/build/Makefile.global
      ${PHP_SOURCE_DIR}/build/php_cxx_compile_stdcxx.m4
      ${PHP_SOURCE_DIR}/build/php.m4
      ${PHP_SOURCE_DIR}/build/pkg.m4
      ${PHP_SOURCE_DIR}/run-tests.php
      ${PHP_SOURCE_DIR}/scripts/phpize.m4
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/php/build
  )

  install(
    PROGRAMS
      ${PHP_SOURCE_DIR}/build/config.guess
      ${PHP_SOURCE_DIR}/build/config.sub
      ${PHP_SOURCE_DIR}/build/shtool
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/php/build
  )
endif()
