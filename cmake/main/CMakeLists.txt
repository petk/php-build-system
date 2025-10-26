#[=============================================================================[
PHP main binding.
#]=============================================================================]

include(CheckSymbolExists)

################################################################################
# Compile and link properties for all binary targets in this directory scope.
################################################################################

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
  PUBLIC
    FILE_SET generated
      TYPE HEADERS
      BASE_DIRS ${PHP_BINARY_DIR}/$<CONFIG>/main
      FILES
        $<$<PLATFORM_ID:Windows>:${PHP_BINARY_DIR}/$<CONFIG>/main/config.w32.h>
        ${PHP_BINARY_DIR}/$<CONFIG>/main/build-defs.h
        $<$<NOT:$<PLATFORM_ID:Windows>>:${PHP_BINARY_DIR}/$<CONFIG>/main/php_config.h>
)

check_symbol_exists(__ELF__ "" PHP_HAS_ELF)
if(PHP_HAS_ELF)
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
    ${PHP_BINARY_DIR}/$<CONFIG>
    ${PHP_BINARY_DIR}/$<CONFIG>/main
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(php_sapi INTERFACE PHP::main)
target_sources(php_sapi INTERFACE $<TARGET_OBJECTS:PHP::main>)

################################################################################
# Add FastCGI target with objects for use in PHP SAPIs such as CGI and FPM.
################################################################################
add_library(php_main_fastcgi OBJECT fastcgi.c)
add_dependencies(php_main_fastcgi php_main)

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
add_dependencies(php_main_internal_functions php_main)
add_dependencies(php_main_internal_functions_cli php_main)

target_sources(
  php_sapi
  INTERFACE
    $<IF:$<BOOL:$<TARGET_PROPERTY:PHP_CLI>>,$<TARGET_OBJECTS:php_main_internal_functions_cli>,$<TARGET_OBJECTS:php_main_internal_functions>>
)

block()
  set(includes "")
  set(includes_cli "")
  set(pointers "")
  set(pointers_cli "")

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
        string(APPEND includes_cli "${code}")
        string(APPEND includes "$<$<NOT:$<BOOL:$<TARGET_GENEX_EVAL:PHP::ext::${extension},$<TARGET_PROPERTY:PHP::ext::${extension},PHP_CLI>>>>:${code}>")
      endif()
    endforeach()

    set(code "\n\tphpext_${extension}_ptr,")
    set(pointers_cli "${pointers_cli}${code}")
    set(pointers "${pointers}$<$<NOT:$<BOOL:$<TARGET_GENEX_EVAL:PHP::ext::${extension},$<TARGET_PROPERTY:PHP::ext::${extension},PHP_CLI>>>>:${code}>")
  endforeach()

  cmake_path(
    RELATIVE_PATH
    CMAKE_CURRENT_BINARY_DIR
    BASE_DIRECTORY ${CMAKE_BINARY_DIR}
    OUTPUT_VARIABLE relative_dir
  )

  file(READ internal_functions.c.in template)

  message(STATUS "Configuring ${relative_dir}/internal_functions.c")
  set(EXT_INCLUDE_CODE "${includes}")
  set(EXT_MODULE_PTRS "${pointers}")
  string(CONFIGURE "${template}" content)
  file(GENERATE OUTPUT internal_functions.c CONTENT "${content}")

  message(STATUS "Configuring ${relative_dir}/internal_functions_cli.c")
  set(EXT_INCLUDE_CODE "${includes_cli}")
  set(EXT_MODULE_PTRS "${pointers_cli}")
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
  OUTPUT_VARIABLE relative_source_dir
)

message(STATUS "Creating ${relative_source_dir}/php_version.h")
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
# When building external libraries with ExternalProject module, the library (and
# its accompanying extension) should be built before the main target so the
# internal functions files have possible library headers available when used in
# extension headers (for example, php_openssl.h, php_zlib.h, etc.).
################################################################################

get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
foreach(extension IN LISTS extensions)
  add_dependencies(php_main PHP::ext::${extension})
endforeach()

################################################################################
# Generate configuration headers.
################################################################################

# Configure build system configuration header (build-defs.h).
function(_php_main_configure_build_defs)
  message(STATUS "Configuring build-defs.h")

  string(CONFIGURE [[
    set(CONFIGURE_COMMAND "cmake")

    if(NOT "@PHP_PEAR_DIR@" STREQUAL "")
      set(PHP_PEAR_INSTALLDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_PEAR_DIR@,${CMAKE_INSTALL_PREFIX}>")
    endif()

    set(PHP_BINDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_BINDIR@,${CMAKE_INSTALL_PREFIX}>")

    if("@CMAKE_SYSTEM_NAME@" STREQUAL "Windows")
      set(PHP_CONFIG_FILE_PATH "")
    else()
      set(PHP_CONFIG_FILE_PATH "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_CONFIG_FILE_PATH@,${CMAKE_INSTALL_PREFIX}>")
    endif()

    set(PHP_CONFIG_FILE_SCAN_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_CONFIG_FILE_SCAN_DIR@,${CMAKE_INSTALL_PREFIX}>")

    set(PHP_DATADIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_DATADIR@,${CMAKE_INSTALL_PREFIX}>")

    set(PHP_EXTENSION_DIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_EXTENSION_DIR@,${CMAKE_INSTALL_PREFIX}>")

    if("@CMAKE_SYSTEM_NAME@" STREQUAL "Windows")
      set(PHP_INCLUDE_PATH ".;${PHP_PEAR_INSTALLDIR}")
    else()
      set(PHP_INCLUDE_PATH ".:${PHP_PEAR_INSTALLDIR}")
    endif()

    set(PHP_LIBDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_LIBDIR@,${CMAKE_INSTALL_PREFIX}>")

    set(PHP_LOCALSTATEDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_LOCALSTATEDIR@,${CMAKE_INSTALL_PREFIX}>")

    if("@CMAKE_SYSTEM_NAME@" STREQUAL "Windows")
      set(PHP_MANDIR "")
    else()
      set(PHP_MANDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_MANDIR@,${CMAKE_INSTALL_PREFIX}>")
    endif()

    set(PHP_PROG_SENDMAIL "@Sendmail_PROGRAM@")

    set(PHP_SBINDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_SBINDIR@,${CMAKE_INSTALL_PREFIX}>")

    if("@CMAKE_SYSTEM_NAME@" STREQUAL "Windows")
      set(PHP_SHLIB_EXT_PREFIX "php_")
    else()
      set(PHP_SHLIB_EXT_PREFIX "")
    endif()

    string(REPLACE "." "" PHP_SHLIB_SUFFIX "@CMAKE_SHARED_MODULE_SUFFIX@")

    set(PHP_SYSCONFDIR "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_SYSCONFDIR@,${CMAKE_INSTALL_PREFIX}>")
  ]] code @ONLY)
  cmake_language(EVAL CODE "${code}")

  file(READ main/cmake/build-defs.h.in content)
  string(CONFIGURE "${content}" content @ONLY)
  file(
    GENERATE
    OUTPUT ${PHP_BINARY_DIR}/$<CONFIG>/main/build-defs.h
    CONTENT "${content}"
  )

  # Regenerate file on the install step when using different installation prefix
  # at the 'cmake --install ... --prefix <install-prefix>' phase.
  string(CONFIGURE [[
    block()
      @code@
      configure_file(
        "@PHP_SOURCE_DIR@/main/cmake/build-defs.h.in"
        "@PHP_BINARY_DIR@/$<CONFIG>/main/build-defs.h"
        @ONLY
      )
    endblock()
  ]] code @ONLY)
  install(CODE "${code}")
endfunction()

# Configure main configuration header (php_config.h, config.w32.h).
function(_php_main_configure_php_config)
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set(PHP_CONFIG_HEADER_GUARD "CONFIG_W32_H")
    set(PHP_CONFIG_H_WINDOWS 1)
    set(file config.w32.h)
  else()
    set(PHP_CONFIG_HEADER_GUARD "PHP_CONFIG_H")
    set(PHP_CONFIG_H_WINDOWS 0)
    set(file php_config.h)
    set(HAVE_BUILD_DEFS_H TRUE)
  endif()

  message(STATUS "Configuring ${file}")

  if(PHP_DEFAULT_SHORT_OPEN_TAG)
    set(DEFAULT_SHORT_OPEN_TAG "1")
  else()
    set(DEFAULT_SHORT_OPEN_TAG "0")
  endif()

  # Add SAPIs configuration.
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

  # Add Windows configuration.
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    file(READ ${CMAKE_CURRENT_BINARY_DIR}/win32/config.h config)
    string(STRIP "${config}" WINDOWS_CONFIGURATION)
  endif()

  file(READ main/cmake/php_config.h.in content)
  string(CONFIGURE "${content}" content @ONLY)
  file(
    GENERATE
    OUTPUT ${PHP_BINARY_DIR}/$<CONFIG>/main/${file}
    CONTENT "${content}"
  )
endfunction()

# Run at the end of the configuration - configure headers and installation.
cmake_language(DEFER DIRECTORY ${PHP_SOURCE_DIR} CALL _php_main_create_files)
function(_php_main_create_files)
  _php_main_configure_build_defs()
  _php_main_configure_php_config()

  install(
    TARGETS php_main
    ARCHIVE EXCLUDE_FROM_ALL
    FILE_SET HEADERS
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/main
    FILE_SET generated
      DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}/main
  )
endfunction()
