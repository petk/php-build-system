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

  set(program_prefix "${PHP_PROGRAM_PREFIX}")
  set(program_suffix "${PHP_PROGRAM_SUFFIX}")
  set(prefix "${CMAKE_INSTALL_PREFIX}")
  set(exec_prefix "${CMAKE_INSTALL_PREFIX}")
  set(includedir "${CMAKE_INSTALL_FULL_INCLUDEDIR}")
  set(datarootdir "${CMAKE_INSTALL_FULL_DATAROOTDIR}")
  # TODO: Add PHP_LDFLAGS.
  set(PHP_LDFLAGS "")
  # TODO: Add EXTRA_LIBS.
  set(EXTRA_LIBS "")
  set(EXTENSION_DIR "${PHP_EXTENSION_DIR}")
  set(mandir "${CMAKE_INSTALL_FULL_MANDIR}")
  set(EXEEXT "${CMAKE_EXECUTABLE_SUFFIX}")
  # TODO: Add CONFIGURE_OPTIONS.
  set(CONFIGURE_OPTIONS "")
  # TODO: Add PHP_INSTALLED_SAPIS.
  set(PHP_INSTALLED_SAPIS "")
  set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}")
  set(EXPANDED_PHP_CONFIG_FILE_PATH "${PHP_CONFIG_FILE_PATH}")
  set(bindir "${CMAKE_INSTALL_FULL_BINDIR}")
  set(SAPI_LIBNAME_SHARED "libphp.so")
  set(SAPI_LIBNAME_STATIC "libphp.a")
  if(TARGET PHP::embed)
    get_target_property(embed_type PHP::embed TYPE)
    if(embed_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      set(PHP_EMBED_TYPE "shared")
    else()
      set(PHP_EMBED_TYPE "static")
    endif()
  endif()
  set(orig_libdir "${CMAKE_INSTALL_FULL_LIBDIR}")

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
  include(PHP/PkgConfigGenerator)
  pkgconfig_generate_pc(
    php.pc.in
    php.pc
    TARGET php_cli
    VARIABLES
      prefix "${CMAKE_INSTALL_PREFIX}"
      exec_prefix "${CMAKE_INSTALL_PREFIX}"
      includedir "${CMAKE_INSTALL_FULL_INCLUDEDIR}"
      libdir "${CMAKE_INSTALL_FULL_LIBDIR}"
      PHP_VERSION "${PHP_VERSION}"
      PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}"
      PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}"
      PHP_CONFIG_FILE_PATH "${PHP_CONFIG_FILE_PATH}"
  )
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
