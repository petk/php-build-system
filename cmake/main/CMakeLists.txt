#[=============================================================================[
PHP main binding.
#]=============================================================================]

include(CheckSymbolExists)

# Compile and link properties for all targets in this directory scope.
add_compile_definitions(ZEND_ENABLE_STATIC_TSRMLS_CACHE)
link_libraries(PHP::config)

################################################################################
# Add library.
################################################################################

add_library(php_main OBJECT)
add_library(PHP::main ALIAS php_main)

target_sources(
  php_main
  PRIVATE
    $<$<NOT:$<PLATFORM_ID:Windows>>:explicit_bzero.c>
    fopen_wrappers.c
    getopt.c
    main.c
    main.stub.php
    network.c
    output.c
    php_content_types.c
    php_glob.c
    php_ini_builder.c
    php_ini.c
    php_odbc_utils.c
    php_open_temporary_file.c
    php_scandir.c
    php_syslog.c
    php_ticks.c
    php_variables.c
    reentrancy.c
    rfc1867.c
    safe_bcmp.c
    SAPI.c
    snprintf.c
    spprintf.c
    streams/cast.c
    streams/filter.c
    streams/glob_wrapper.c
    streams/memory.c
    streams/mmap.c
    streams/plain_wrapper.c
    streams/streams.c
    streams/transports.c
    streams/userspace.c
    streams/userspace.stub.php
    streams/xp_socket.c
    strlcat.c
    strlcpy.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        charclass.h
        fastcgi.h
        fopen_wrappers.h
        http_status_codes.h
        main_arginfo.h
        php_compat.h
        php_content_types.h
        php_getopt.h
        php_glob.h
        php_globals.h
        php_ini_builder.h
        php_ini.h
        php_main.h
        php_memory_streams.h
        php_network.h
        php_odbc_utils.h
        php_open_temporary_file.h
        php_output.h
        php_reentrancy.h
        php_scandir.h
        php_streams.h
        php_syslog.h
        php_ticks.h
        php_variables.h
        php_version.h
        php.h
        rfc1867.h
        SAPI.h
        snprintf.h
        spprintf.h
        streams/php_stream_context.h
        streams/php_stream_filter_api.h
        streams/php_stream_glob_wrapper.h
        streams/php_stream_mmap.h
        streams/php_stream_plain_wrapper.h
        streams/php_stream_transport.h
        streams/php_stream_userspace.h
        streams/php_streams_int.h
        streams/userspace_arginfo.h
  PUBLIC
    FILE_SET generated
      TYPE HEADERS
      BASE_DIRS ${CMAKE_CURRENT_BINARY_DIR}
      FILES
        $<$<PLATFORM_ID:Windows>:${CMAKE_CURRENT_BINARY_DIR}/config.w32.h>
        $<$<NOT:$<PLATFORM_ID:Windows>>:${CMAKE_CURRENT_BINARY_DIR}/build-defs.h>
        $<$<NOT:$<PLATFORM_ID:Windows>>:${CMAKE_CURRENT_BINARY_DIR}/php_config.h>
)

check_symbol_exists(__ELF__ "" _HAVE_ELF)
if(_HAVE_ELF)
  target_sources(
    php_main
    PRIVATE
      $<$<CONFIG:Debug,DebugAssertions,RelWithDebInfo>:debug_gdb_scripts.c>
  )

  # Regenerate main/debug_gdb_scripts.c after PHP cli SAPI has been built.
  include(PHP/AddCustomCommand)
  php_add_custom_command(
    php_main_generate_debug_gdb_scripts
    OUTPUT
      ${CMAKE_CURRENT_SOURCE_DIR}/debug_gdb_scripts.c
    DEPENDS
      ${PHP_SOURCE_DIR}/scripts/gdb/debug_gdb_scripts_gen.php
      ${PHP_SOURCE_DIR}/scripts/gdb/php_gdb.py
      ${PHP_SOURCE_DIR}/.gdbinit
    PHP_COMMAND
      ${PHP_SOURCE_DIR}/scripts/gdb/debug_gdb_scripts_gen.php
    COMMENT
      "[main] Regenerating main/debug_gdb_scripts.c"
    VERBATIM
  )
endif()

################################################################################
# Add usage requirements to PHP interface targets.
################################################################################

target_compile_definitions(
  php_config
  INTERFACE
    $<$<PLATFORM_ID:Windows>:SAPI_EXPORTS>
)

target_include_directories(
  php_config
  INTERFACE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(php_sapi INTERFACE PHP::main)
target_sources(php_sapi INTERFACE $<TARGET_OBJECTS:PHP::main>)

################################################################################
# Add FastCGI target with objects for use in PHP SAPIs such as CGI and FPM.
################################################################################
add_library(php_main_fastcgi OBJECT fastcgi.c)

target_sources(
  php_sapi
  INTERFACE
    $<$<BOOL:$<TARGET_PROPERTY:PHP_SAPI_FASTCGI>>:$<TARGET_OBJECTS:php_main_fastcgi>>
)

################################################################################
# Create main/internal_functions*.c files with a list of static enabled PHP
# extensions based on the PHP SAPI type.
################################################################################

add_library(php_main_internal_functions OBJECT internal_functions.c)
add_library(php_main_internal_functions_cli OBJECT internal_functions_cli.c)

target_sources(
  php_sapi
  INTERFACE
    $<IF:$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>,$<TARGET_OBJECTS:php_main_internal_functions_cli>,$<TARGET_OBJECTS:php_main_internal_functions>>
)

block()
  set(includes "")
  set(includesCli "")
  set(pointers "")
  set(pointersCli "")

  get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
  foreach(extension IN LISTS extensions)
    # Skip if extension is shared.
    get_target_property(type PHP::ext::${extension} TYPE)
    if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      continue()
    endif()

    file(GLOB_RECURSE headers ${PHP_SOURCE_DIR}/ext/${extension}/*.h)

    foreach(header IN LISTS headers)
      file(READ "${header}" content)
      string(FIND "${content}" "phpext_" index)

      if(NOT index EQUAL -1)
        cmake_path(GET header FILENAME filename)
        set(code "#include \"ext/${extension}/${filename}\"\n")
        string(APPEND includesCli "${code}")
        string(APPEND includes "$<$<NOT:$<BOOL:$<TARGET_GENEX_EVAL:PHP::ext::${extension},$<TARGET_PROPERTY:PHP::ext::${extension},PHP_CLI>>>>:${code}>")
      endif()
    endforeach()

    set(code "\n\tphpext_${extension}_ptr,")
    set(pointersCli "${pointersCli}${code}")
    set(pointers "${pointers}$<$<NOT:$<BOOL:$<TARGET_GENEX_EVAL:PHP::ext::${extension},$<TARGET_PROPERTY:PHP::ext::${extension},PHP_CLI>>>>:${code}>")
  endforeach()

  cmake_path(
    RELATIVE_PATH
    CMAKE_CURRENT_BINARY_DIR
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE relativeBinaryDir
  )

  file(READ internal_functions.c.in template)

  message(STATUS "Configuring ${relativeBinaryDir}/internal_functions.c")
  set(EXT_INCLUDE_CODE "${includes}")
  set(EXT_MODULE_PTRS "${pointers}")
  string(CONFIGURE "${template}" content)
  file(GENERATE OUTPUT internal_functions.c CONTENT "${content}")

  message(STATUS "Configuring ${relativeBinaryDir}/internal_functions_cli.c")
  set(EXT_INCLUDE_CODE "${includesCli}")
  set(EXT_MODULE_PTRS "${pointersCli}")
  string(CONFIGURE "${template}" content)
  file(GENERATE OUTPUT internal_functions_cli.c CONTENT "${content}")
endblock()

################################################################################
# Create main/php_version.h. Template is based on the configure.ac.
################################################################################

cmake_path(
  RELATIVE_PATH
  CMAKE_CURRENT_SOURCE_DIR
  BASE_DIRECTORY ${CMAKE_SOURCE_DIR}
  OUTPUT_VARIABLE relativeSourceDir
)

message(STATUS "Creating ${relativeSourceDir}/php_version.h")
file(CONFIGURE OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/php_version.h CONTENT [[
/* automatically generated by configure */
/* edit configure.ac to change version number */
#define PHP_MAJOR_VERSION @PHP_VERSION_MAJOR@
#define PHP_MINOR_VERSION @PHP_VERSION_MINOR@
#define PHP_RELEASE_VERSION @PHP_VERSION_PATCH@
#define PHP_EXTRA_VERSION "@PHP_VERSION_LABEL@"
#define PHP_VERSION "@PHP_VERSION@"
#define PHP_VERSION_ID @PHP_VERSION_ID@
]])

################################################################################
# Generate configuration headers.
################################################################################

# Run at the end of the configuration.
cmake_language(DEFER DIRECTORY ${PHP_SOURCE_DIR} CALL _php_main_create_files)
function(_php_main_create_files)
  ##############################################################################
  # Map CMake variable names to names in PHP configuration headers where needed.
  ##############################################################################

  # TODO: Set configure command string.
  set(CONFIGURE_COMMAND "cmake")

  # TODO: Fix the installation prefixes below when passed via the '--prefix'
  # option of the 'cmake --install ...' command. PHP is at the time of writing
  # not a relocatable program.

  if(PHP_PEAR_DIR)
    set(
      EXPANDED_PEAR_INSTALLDIR
      "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_PEAR_DIR},${CMAKE_INSTALL_PREFIX}>"
    )
  endif()

  # Set the 'include_path' INI directive.
  set(
    INCLUDE_PATH
    ".$<IF:$<PLATFORM_ID:Windows>,;,:>${EXPANDED_PEAR_INSTALLDIR}"
  )

  # Set the PHP extensions directory.
  set(
    EXPANDED_EXTENSION_DIR
    "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_EXTENSION_DIR},${CMAKE_INSTALL_PREFIX}>"
  )

  # Set the directory where php.ini is looked for.
  set(
    EXPANDED_PHP_CONFIG_FILE_PATH
    "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_PATH},${CMAKE_INSTALL_PREFIX}>"
  )

  # Set the directory where additional ini files are searched for.
  set(
    EXPANDED_PHP_CONFIG_FILE_SCAN_DIR
    "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_SCAN_DIR},${CMAKE_INSTALL_PREFIX}>"
  )

  set(
    EXPANDED_BINDIR
    "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_BINDIR},${CMAKE_INSTALL_PREFIX}>"
  )

  set(
    EXPANDED_SBINDIR
    "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_SBINDIR},${CMAKE_INSTALL_PREFIX}>"
  )

  set(
    EXPANDED_MANDIR
    "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_MANDIR},${CMAKE_INSTALL_PREFIX}>"
  )

  set(
    EXPANDED_LIBDIR
    "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LIBDIR},${CMAKE_INSTALL_PREFIX}>"
  )

  set(
    EXPANDED_DATADIR
    "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_DATADIR},${CMAKE_INSTALL_PREFIX}>"
  )

  set(EXPANDED_SYSCONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
  set(EXPANDED_LOCALSTATEDIR "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}")
  set(prefix "${CMAKE_INSTALL_PREFIX}")

  # Set shared library object extension.
  string(REPLACE "." "" SHLIB_DL_SUFFIX_NAME ${CMAKE_SHARED_MODULE_SUFFIX})

  if(PHP_DEFAULT_SHORT_OPEN_TAG)
    set(DEFAULT_SHORT_OPEN_TAG "1")
  else()
    set(DEFAULT_SHORT_OPEN_TAG "0")
  endif()

  # Add sapis configuration.
  set(config "")
  get_property(sapis GLOBAL PROPERTY PHP_SAPIS)
  list(SORT sapis COMPARE NATURAL)
  foreach(sapi IN LISTS sapis)
    if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/sapi/${sapi}/config.h)
      file(READ ${CMAKE_CURRENT_BINARY_DIR}/sapi/${sapi}/config.h content)
      if(content)
        string(APPEND config "\n${content}")
      endif()
    endif()
  endforeach()
  string(STRIP "${config}" PHP_SAPIS_CONFIGURATION)

  # Add extensions configuration.
  set(config "")
  get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
  list(SORT extensions COMPARE NATURAL)
  foreach(extension IN LISTS extensions)
    if(EXISTS ${CMAKE_CURRENT_BINARY_DIR}/ext/${extension}/config.h)
      file(READ ${CMAKE_CURRENT_BINARY_DIR}/ext/${extension}/config.h content)
      if(content)
        string(APPEND config "\n${content}")
      endif()
    endif()
  endforeach()
  string(STRIP "${config}" PHP_EXTENSIONS_CONFIGURATION)

  # Add Zend Engine configuration.
  file(READ ${CMAKE_CURRENT_BINARY_DIR}/Zend/CMakeFiles/zend_config.h config)
  string(STRIP "${config}" ZEND_CONFIGURATION)

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(PHP_CONFIG_H_WINDOWS 1)
    set(file config.w32.h)
  else()
    set(ODBC_CFLAGS "${PHP_ODBC_CFLAGS}")
    set(ODBC_LFLAGS "${PHP_ODBC_LFLAGS}")
    set(ODBC_LIBS "${PHP_ODBC_LIBS}")
    set(ODBC_TYPE "${PHP_ODBC_TYPE}")
    message(STATUS "Creating main/build-defs.h")
    file(READ main/build-defs.h.in content)
    string(CONFIGURE "${content}" content @ONLY)

    # To be able to evaluate the generator expressions.
    file(
      GENERATE
      # TODO: Multi-config generators need to write separate files.
      #OUTPUT $<CONFIG>/main/build-defs.h
      OUTPUT main/build-defs.h
      CONTENT "${content}"
    )

    #[[
    TODO: This enables regenerating the build-defs.h file on the install step
    when using different install prefix at the 'cmake --install ... --prefix'
    phase. Needs to be adjusted further to rebuild PHP at such case.
    include(PHP/ConfigureFile)
    php_configure_file(
      INPUT ${PHP_SOURCE_DIR}/main/build-defs.h.in
      OUTPUT ${PHP_BINARY_DIR}/main/build-defs.h
      VARIABLES
        CONFIGURE_COMMAND "cmake"
        ODBC_CFLAGS "${PHP_ODBC_CFLAGS}"
        ODBC_LFLAGS "${PHP_ODBC_LFLAGS}"
        ODBC_LIBS "${PHP_ODBC_LIBS}"
        ODBC_TYPE "${PHP_ODBC_TYPE}"
        PROG_SENDMAIL "${PROG_SENDMAIL}"
        EXPANDED_PEAR_INSTALLDIR "${EXPANDED_PEAR_INSTALLDIR}"
        INCLUDE_PATH "${INCLUDE_PATH}"
        EXPANDED_EXTENSION_DIR "${EXPANDED_EXTENSION_DIR}"
        prefix "$<INSTALL_PREFIX>"
        EXPANDED_BINDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_BINDIR},$<INSTALL_PREFIX>>"
        EXPANDED_SBINDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_SBINDIR},$<INSTALL_PREFIX>>"
        EXPANDED_MANDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_MANDIR},$<INSTALL_PREFIX>>"
        EXPANDED_LIBDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LIBDIR},$<INSTALL_PREFIX>>"
        EXPANDED_DATADIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_DATADIR},$<INSTALL_PREFIX>>"
        EXPANDED_SYSCONFDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_SYSCONFDIR},$<INSTALL_PREFIX>>"
        EXPANDED_LOCALSTATEDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_LOCALSTATEDIR},$<INSTALL_PREFIX>>"
        EXPANDED_PHP_CONFIG_FILE_PATH "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_PATH},$<INSTALL_PREFIX>>"
        EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,${PHP_CONFIG_FILE_SCAN_DIR},$<INSTALL_PREFIX>>"
        SHLIB_DL_SUFFIX_NAME "${SHLIB_DL_SUFFIX_NAME}"
    )
    add_custom_target(php_main_build_defs_h DEPENDS ${PHP_BINARY_DIR}/main/build-defs.h)
    add_dependencies(php_main php_main_build_defs_h)
    #]]

    set(HAVE_BUILD_DEFS_H TRUE)
    set(PHP_CONFIG_H_WINDOWS 0)
    set(file php_config.h)
  endif()

  message(STATUS "Creating main/${file}")
  file(READ main/cmake/php_config.h.in content)
  string(CONFIGURE "${content}" content @ONLY)

  file(
    GENERATE
    # TODO: Multi-config generators need to write separate files.
    #OUTPUT $<CONFIG>/main/${file}
    OUTPUT main/${file}
    CONTENT "${content}"
  )
endfunction()

################################################################################
# Configure installation.
################################################################################

install(
  TARGETS php_main
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/main
  FILE_SET generated
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/main
)
