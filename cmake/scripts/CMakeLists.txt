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

# The php-config and phpize scripts.
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

  ##############################################################################
  message(STATUS "Creating scripts/php-config")
  ##############################################################################

  get_property(sapis GLOBAL PROPERTY PHP_SAPIS)
  set(sapis "$<JOIN:$<LIST:SORT,${sapis}>, >")

  # Replace the upstream php-config script hardcoded php include directory to a
  # template placeholder.
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/php-config.in" content)
  string(
    REPLACE
    [[include_dir="@includedir@/php"]]
    [[include_dir="@includedir@"]]
    content
    "${content}"
  )

  file(
    WRITE
    "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/php-config.in"
    "${content}"
  )

  if(TARGET PHP::sapi::embed)
    get_target_property(embed_type PHP::sapi::embed TYPE)
    if(embed_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      set(PHP_EMBED_TYPE "shared")
    else()
      set(PHP_EMBED_TYPE "static")
    endif()
  endif()

  string(CONFIGURE [[
    set(SED "@SED@")
    set(prefix "${CMAKE_INSTALL_PREFIX}")
    set(datarootdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_DATAROOTDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(exec_prefix "${CMAKE_INSTALL_PREFIX}")
    set(PHP_VERSION "@PHP_VERSION@")
    set(PHP_VERSION_ID "@PHP_VERSION_ID@")
    set(includedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_INCLUDEDIR@/@PHP_INCLUDE_PREFIX@,${CMAKE_INSTALL_PREFIX}>")
    # TODO:
    set(PHP_LDFLAGS "")
    # TODO:
    set(EXTRA_LIBS "")
    set(EXTENSION_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_EXTENSION_DIR@,${CMAKE_INSTALL_PREFIX}>")
    set(mandir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_MANDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(program_prefix "@PHP_PROGRAM_PREFIX@")
    set(program_suffix "@PHP_PROGRAM_SUFFIX@")
    set(EXEEXT "@CMAKE_EXECUTABLE_SUFFIX@")
    # TODO:
    set(CONFIGURE_OPTIONS "")
    set(PHP_INSTALLED_SAPIS "@sapis@")
    set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_CONFIG_FILE_SCAN_DIR@,${CMAKE_INSTALL_PREFIX}>")
    set(EXPANDED_PHP_CONFIG_FILE_PATH "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_CONFIG_FILE_PATH@,${CMAKE_INSTALL_PREFIX}>")
    set(bindir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_BINDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(orig_libdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_LIBDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(SAPI_LIBNAME_SHARED "$<$<TARGET_EXISTS:php_sapi_embed_shared>:$<GENEX_EVAL:$<TARGET_FILE_NAME:php_sapi_embed_shared>>>")
    set(SAPI_LIBNAME_STATIC "$<$<TARGET_EXISTS:php_sapi_embed>:$<GENEX_EVAL:$<TARGET_FILE_NAME:php_sapi_embed>>>")
    set(PHP_EMBED_TYPE "@PHP_EMBED_TYPE@")
  ]] code @ONLY)
  cmake_language(EVAL CODE "${code}")
  string(CONFIGURE "${content}" content @ONLY)
  file(
    GENERATE
    OUTPUT ${PHP_BINARY_DIR}/$<CONFIG>/scripts/php-config
    CONTENT "${content}"
  )

  # Regenerate file on the install step when using different installation prefix
  # at the 'cmake --install ... --prefix <install-prefix>' phase.
  string(CONFIGURE [[
    @code@
    configure_file(
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/PHP/php-config.in"
      "@PHP_BINARY_DIR@/$<CONFIG>/scripts/php-config"
      @ONLY
    )
  ]] code @ONLY)
  install(CODE "${code}")

  install(
    PROGRAMS
    ${PHP_BINARY_DIR}/$<CONFIG>/scripts/php-config
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME ${PHP_PROGRAM_PREFIX}php-config${PHP_PROGRAM_SUFFIX}
  )

  ##############################################################################
  message(STATUS "Creating scripts/phpize")
  ##############################################################################

  # Patch phpize template: Replace the upstream phpize script hardcoded php
  # include directory to a template placeholder.
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/phpize.in" content)
  string(
    REPLACE
    [[includedir="`eval echo @includedir@`/php"]]
    [[includedir="@includedir@"]]
    content
    "${content}"
  )
  file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/phpize.in" "${content}")

  string(CONFIGURE [[
    set(prefix "${CMAKE_INSTALL_PREFIX}")
    set(datarootdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_DATAROOTDIR@,${CMAKE_INSTALL_PREFIX}>")
    set(exec_prefix "${CMAKE_INSTALL_PREFIX}")
    set(libdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_LIBDIR@/php,${CMAKE_INSTALL_PREFIX}>")
    set(includedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_INCLUDEDIR@/@PHP_INCLUDE_PREFIX@,${CMAKE_INSTALL_PREFIX}>")
    set(SED "@SED@")
  ]] code @ONLY)
  cmake_language(EVAL CODE "${code}")
  string(CONFIGURE "${content}" content @ONLY)
  file(GENERATE OUTPUT phpize CONTENT "${content}")

  # Regenerate file on the install step when using different installation prefix
  # at the 'cmake --install ... --prefix <install-prefix>' phase.
  string(CONFIGURE [[
    @code@
    configure_file(
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/PHP/phpize.in"
      "@CMAKE_CURRENT_BINARY_DIR@/phpize"
      @ONLY
    )
  ]] code @ONLY)
  install(CODE "${code}")

  install(
    PROGRAMS
    ${CMAKE_CURRENT_BINARY_DIR}/phpize
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    RENAME ${PHP_PROGRAM_PREFIX}phpize${PHP_PROGRAM_SUFFIX}
  )
endblock()

# Configure pkg-config php.pc metadata file.
include(PHP/PkgConfig)
php_pkgconfig_generate_pc(
  php.pc.in
  php.pc
  TARGET PHP::sapi::cli
  VARIABLES
    prefix "$<INSTALL_PREFIX>"
    exec_prefix "$<INSTALL_PREFIX>"
    includedir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_INCLUDEDIR},$<INSTALL_PREFIX>>"
    php_include_prefix "${PHP_INCLUDE_PREFIX}"
    libdir "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LIBDIR},$<INSTALL_PREFIX>>"
    PHP_VERSION "${PHP_VERSION}"
    PHP_VERSION_ID "${PHP_VERSION_ID}"
    PHP_EXTENSION_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_EXTENSION_DIR},$<INSTALL_PREFIX>>"
    PHP_CONFIG_FILE_SCAN_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_SCAN_DIR},$<INSTALL_PREFIX>>"
    PHP_CONFIG_FILE_PATH "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_PATH},$<INSTALL_PREFIX>>"
    PHP_DEBUG "$<IF:$<CONFIG:Debug,DebugAssertions>,yes,no>"
    PHP_THREAD_SAFETY "$<IF:$<BOOL:$<TARGET_PROPERTY:PHP::config,PHP_THREAD_SAFETY>>,yes,no>"
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/php.pc
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
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
