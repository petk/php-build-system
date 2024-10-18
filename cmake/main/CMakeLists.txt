include(CheckSymbolExists)
include(FeatureSummary)

add_library(php_main STATIC)
add_library(PHP::main ALIAS php_main)

target_sources(
  php_main
  PRIVATE
    $<$<NOT:$<PLATFORM_ID:Windows>>:explicit_bzero.c>
    fastcgi.c
    fopen_wrappers.c
    getopt.c
    internal_functions_cli.c
    internal_functions.c
    main.c
    main.stub.php
    network.c
    output.c
    php_content_types.c
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
        fastcgi.h
        fopen_wrappers.h
        http_status_codes.h
        main_arginfo.h
        php_compat.h
        php_content_types.h
        php_getopt.h
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
  # A separate file set so binary dir can also be created within a source dir.
  PUBLIC
    FILE_SET HEADERS
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
  file(
    GENERATE
    OUTPUT CMakeFiles/GenerateDebugGDBScripts.cmake
    CONTENT [[
      if(EXISTS ${PHP_EXECUTABLE})
        execute_process(
          COMMAND ${PHP_EXECUTABLE}
            ${PHP_SOURCE_DIR}/scripts/gdb/debug_gdb_scripts_gen.php
        )
      endif()
    ]]
  )

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/debug_gdb_scripts.c
    COMMAND ${CMAKE_COMMAND}
            -D PHP_EXECUTABLE=${PHP_BINARY_DIR}/sapi/cli/php
            -D PHP_SOURCE_DIR=${PHP_SOURCE_DIR}
            -P CMakeFiles/GenerateDebugGDBScripts.cmake
    DEPENDS
      ${PHP_SOURCE_DIR}/scripts/gdb/debug_gdb_scripts_gen.php
      ${PHP_SOURCE_DIR}/scripts/gdb/php_gdb.py
      ${PHP_SOURCE_DIR}/.gdbinit
    COMMENT "[main] Regenerating main/debug_gdb_scripts.c"
    VERBATIM
  )
endif()

target_compile_definitions(
  php_main
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<PLATFORM_ID:Windows>:SAPI_EXPORTS>
)

target_include_directories(
  php_main
  INTERFACE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Add main PUBLIC/INTERFACE include directories to configuration.
target_include_directories(
  php_configuration
  INTERFACE
    $<TARGET_PROPERTY:PHP::main,INTERFACE_INCLUDE_DIRECTORIES>
)

target_link_libraries(
  php_main
  # Link publicly for PHP SAPIs.
  PUBLIC
    PHP::configuration
    $<$<TARGET_EXISTS:PHP::win32>:PHP::win32>
)

# Add DTrace.
if(PHP_DTRACE)
  message(CHECK_START "Checking for DTrace support")

  find_package(DTrace)
  set_package_properties(
    DTrace
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the DTrace support."
  )

  if(DTrace_FOUND)
    dtrace_target(
      TARGET php_main
      INPUT ${PHP_SOURCE_DIR}/Zend/zend_dtrace.d
      HEADER ${PHP_BINARY_DIR}/Zend/zend_dtrace_gen.h
      SOURCES
        ${PHP_SOURCE_DIR}/main/main.c
        ${PHP_SOURCE_DIR}/Zend/zend_API.c
        ${PHP_SOURCE_DIR}/Zend/zend_dtrace.c
        ${PHP_SOURCE_DIR}/Zend/zend_exceptions.c
        ${PHP_SOURCE_DIR}/Zend/zend_execute.c
        ${PHP_SOURCE_DIR}/Zend/zend.c
      INCLUDES
        $<TARGET_PROPERTY:PHP::configuration,INTERFACE_INCLUDE_DIRECTORIES>
    )

    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

# Add Dmalloc.
if(PHP_DMALLOC)
  message(CHECK_START "Checking for Dmalloc support")

  find_package(Dmalloc)
  set_package_properties(
    Dmalloc
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to use Dmalloc memory debugger."
  )

  target_compile_definitions(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:MALLOC_FUNC_CHECK>
  )

  target_link_libraries(php_main PRIVATE Dmalloc::Dmalloc)

  if(Dmalloc_FOUND)
    message(CHECK_PASS "yes")
    set(HAVE_DMALLOC 1 CACHE INTERNAL "Whether the Dmalloc library is available")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

get_cmake_property(extensions PHP_EXTENSIONS)
foreach(extension IN LISTS extensions)
  # Add extension's PUBLIC/INTERFACE compile options to configuration.
  # Cleaner COMPILE_ONLY generator expression is available in CMake >= 3.27.
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.27)
    target_link_libraries(php_configuration
      INTERFACE $<COMPILE_ONLY:PHP::${extension}>
    )
  else()
    target_include_directories(
      php_configuration
      INTERFACE
        $<TARGET_PROPERTY:PHP::${extension},INTERFACE_INCLUDE_DIRECTORIES>
    )
  endif()

  target_link_libraries(php_${extension} PRIVATE PHP::configuration)

  # Add configuration compile options before the extension compile options.
  target_compile_options(
    php_${extension}
    BEFORE PRIVATE
      $<TARGET_PROPERTY:php_configuration,INTERFACE_COMPILE_OPTIONS>
  )

  get_target_property(extension_type php_${extension} TYPE)

  if(extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
    set_target_properties(
      php_${extension}
      PROPERTIES
        POSITION_INDEPENDENT_CODE TRUE
    )
  else()
    target_link_libraries(php_main PRIVATE PHP::${extension})
  endif()

  add_dependencies(php_${extension} zend)
endforeach()

################################################################################
# Generate files and install headers.
################################################################################

# Create main/internal_functions*.c files based on the enabled extensions.
function(_php_main_create_internal_functions)
  # Create main/internal_functions* files.
  set(EXT_INCLUDE_CODE "")
  set(EXT_MODULE_PTRS "")

  # Add artifacts of static enabled PHP extensions to symbol definitions.
  get_cmake_property(php_extensions PHP_EXTENSIONS)
  foreach(extension IN LISTS php_extensions)
    # Skip if extension is shared.
    get_target_property(extension_type php_${extension} TYPE)
    if(extension_type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      continue()
    endif()

    file(GLOB_RECURSE extension_headers ${PHP_SOURCE_DIR}/ext/${extension}/*.h)

    foreach(extension_header IN LISTS extension_headers)
      file(READ "${extension_header}" file_content)
      string(FIND "${file_content}" "phpext_" pattern_index)

      if(NOT pattern_index EQUAL -1)
        cmake_path(GET extension_header FILENAME file_name)
        string(
          APPEND
          EXT_INCLUDE_CODE
          "#include \"ext/${extension}/${file_name}\"\n"
        )
      endif()
    endforeach()

    set(EXT_MODULE_PTRS "${EXT_MODULE_PTRS}\n\tphpext_${extension}_ptr,")
  endforeach()

  message(STATUS "Creating main/internal_functions.c")
  configure_file(main/internal_functions.c.in main/internal_functions.c)

  message(STATUS "Creating main/internal_functions_cli.c")
  configure_file(main/internal_functions.c.in main/internal_functions_cli.c)
endfunction()

# Create PHP configuration headers.
function(_php_main_create_files)
  _php_main_create_internal_functions()

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

  message(STATUS "Creating main/php_version.h")
  configure_file(main/php_version.h.in main/php_version.h @ONLY)

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(PHP_CONFIG_H_WINDOWS 1)
    set(file config.w32.h)
  else()
    message(STATUS "Creating main/build-defs.h")
    file(READ main/build-defs.h.in content)
    string(CONFIGURE "${content}" content @ONLY)

    # To be able to evaluate the generator expressions.
    file(
      GENERATE
      # TODO: Multi-config generators need to write separate files.
      #OUTPUT $<CONFIG>/main/build-defs.h
      OUTPUT ${PHP_BINARY_DIR}/main/build-defs.h
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
        ODBC_CFLAGS "${ODBC_CFLAGS}"
        ODBC_LFLAGS "${ODBC_LFLAGS}"
        ODBC_LIBS "${ODBC_LIBS}"
        ODBC_TYPE "${ODBC_TYPE}"
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

    set(HAVE_BUILD_DEFS_H 1)
    set(PHP_CONFIG_H_WINDOWS 0)
    set(file php_config.h)
  endif()

  message(STATUS "Creating main/${file}")
  file(READ main/php_config.cmake.h.in content)
  string(CONFIGURE "${content}" content @ONLY)

  file(
    GENERATE
    # TODO: Multi-config generators need to write separate files.
    #OUTPUT $<CONFIG>/main/${file}
    OUTPUT ${PHP_BINARY_DIR}/main/${file}
    CONTENT "${content}"
  )
endfunction()

# Run at the end of the configuration.
cmake_language(
  DEFER
    DIRECTORY ${PHP_SOURCE_DIR}
  CALL _php_main_create_files
)

install(
  TARGETS php_main
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/main
)
