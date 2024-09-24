include(CheckSymbolExists)
include(FeatureSummary)

add_library(php_main STATIC)
add_library(PHP::main ALIAS php_main)

file(GLOB_RECURSE _php_main_headers ${CMAKE_CURRENT_SOURCE_DIR}/*.h)

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
    streams/xp_socket.c
    strlcat.c
    strlcpy.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        ${_php_main_headers}
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
    Zend::Zend
)

if(TARGET PHP::win32)
  target_link_libraries(php_main PUBLIC PHP::win32)
endif()

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
  # Set the 'include_path' INI directive.
  set(INCLUDE_PATH ".:${EXPANDED_PEAR_INSTALLDIR}")
  # TODO: Fix the installation prefix when passed via --prefix option.
  set(EXPANDED_EXTENSION_DIR "${PHP_FULL_EXTENSION_DIR}")
  set(EXPANDED_PHP_CONFIG_FILE_PATH "${PHP_FULL_CONFIG_FILE_PATH}")
  set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_FULL_CONFIG_FILE_SCAN_DIR}")
  set(EXPANDED_BINDIR "${CMAKE_INSTALL_FULL_BINDIR}")
  set(EXPANDED_SBINDIR "${CMAKE_INSTALL_FULL_SBINDIR}")
  set(EXPANDED_MANDIR "${CMAKE_INSTALL_FULL_MANDIR}")
  set(EXPANDED_LIBDIR "${CMAKE_INSTALL_FULL_LIBDIR}")
  set(EXPANDED_DATADIR "${CMAKE_INSTALL_FULL_DATADIR}")
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

  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    message(STATUS "Creating main/config.w32.h")
    configure_file(
      main/config.w32.cmake.h.in
      main/CMakeFiles/config.w32.cmake.h.in
      @ONLY
    )

    file(
      GENERATE
      # TODO: Multi-config generators need to write separate files.
      #OUTPUT $<CONFIG>/main/config.w32.h
      OUTPUT ${PHP_BINARY_DIR}/main/config.w32.h
      INPUT ${PHP_BINARY_DIR}/main/CMakeFiles/config.w32.cmake.h.in
    )
  else()
    message(STATUS "Creating main/build-defs.h")
    configure_file(
      main/build-defs.h.in
      main/CMakeFiles/build-defs.h.in
      @ONLY
    )

    # To be able to evaluate the generator expressions.
    file(
      GENERATE
      # TODO: Multi-config generators need to write separate files.
      #OUTPUT $<CONFIG>/main/build-defs.h
      OUTPUT ${PHP_BINARY_DIR}/main/build-defs.h
      INPUT ${PHP_BINARY_DIR}/main/CMakeFiles/build-defs.h.in
    )

    set(HAVE_BUILD_DEFS_H 1)

    message(STATUS "Creating main/php_config.h")
    configure_file(
      main/php_config.cmake.h.in
      main/CMakeFiles/php_config.cmake.h.in
      @ONLY
    )

    # To be able to evaluate the generator expressions.
    file(
      GENERATE
      # TODO: Multi-config generators need to write separate files.
      #OUTPUT $<CONFIG>/main/php_config.h
      OUTPUT ${PHP_BINARY_DIR}/main/php_config.h
      INPUT ${PHP_BINARY_DIR}/main/CMakeFiles/php_config.cmake.h.in
    )
  endif()

  message(STATUS "Creating main/php_version.h")
  configure_file(main/php_version.h.in main/php_version.h @ONLY)
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
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/main
)
