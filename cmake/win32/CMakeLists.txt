# For Windows only.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(FeatureSummary)

################################################################################
# Add library.
################################################################################

add_library(php_windows OBJECT)
add_library(PHP::windows ALIAS php_windows)

target_sources(
  php_windows
  PRIVATE
    codepage.c
    console.c
    dllmain.c
    fnmatch.c
    ftok.c
    getrusage.c
    glob.c
    globals.c
    ioutil.c
    nice.c
    readdir.c
    registry.c
    select.c
    sendmail.c
    signal.c
    sockets.c
    time.c
    winutil.c
    wsyslog.c
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS ${PHP_SOURCE_DIR}
      FILES
        codepage.h
        console.h
        fnmatch.h
        getrusage.h
        glob.h
        ioutil.h
        ipc.h
        nice.h
        param.h
        php_registry.h
        php_win32_globals.h
        readdir.h
        select.h
        sendmail.h
        signal.h
        sockets.h
        syslog.h
        time.h
        unistd.h
        winutil.h
  PUBLIC
    FILE_SET generated
      TYPE HEADERS
      BASE_DIRS ${PHP_BINARY_DIR}
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/wsyslog.h
)

target_include_directories(php_windows PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(php_windows PRIVATE PHP::config)

################################################################################
# Add usage requirements to PHP interface targets.
################################################################################

target_compile_definitions(
  php_config
  INTERFACE
    # Marks that target system is Windows. For PHP code.
    PHP_WIN32

    # This preprocessor macro is also defined by all compilers when targeting
    # Windows. It is left here to match the native PHP Windows build system.
    _WIN32

    # This preprocessor macro is also defined by Windows SDK and some compilers
    # (GCC and Clang) when targeting Windows. Left here for BC for possible PECL
    # extensions not being updated yet. In new code it is being replaced with
    # _WIN32.
    WIN32

    # For Zend Engine, same as PHP_WIN32.
    ZEND_WIN32

    _MBCS
    _USE_MATH_DEFINES
    PHP_EXPORTS

    # The time_t defaults to 64-bit. Force 32-bit time_t on 32-bit architecture.
    # This was historically added to PHP as Visual Studio 2005 set 64-bit time_t
    # by default and it would break 3rdParty libs that were built with older
    # compilers. This and duplicate definition in the configuration header
    # should be removed at some point.
    $<$<EQUAL:${CMAKE_SIZEOF_VOID_P},4>:_USE_32BIT_TIME_T=1>
)

# MS deprecated ANSI stdio and similar functions. Disable warnings.
target_compile_options(
  php_config
  INTERFACE
    $<$<COMPILE_LANG_AND_ID:C,MSVC>:/wd4996>
    $<$<COMPILE_LANG_AND_ID:CXX,MSVC>:/wd4996>
)

target_link_libraries(
  php_config
  INTERFACE
    advapi32
    bcrypt
    Dnsapi
    kernel32
    ole32
    psapi
    shell32
    user32
    ws2_32
)

target_link_libraries(php_sapi INTERFACE PHP::windows)
target_sources(php_sapi INTERFACE $<TARGET_OBJECTS:PHP::windows>)

################################################################################
# Generate wsyslog.h file with message compiler (mc).
################################################################################

find_package(MC)
set_package_properties(
  MC
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to generate win32/wsyslog.h."
)

mc_target(
  NAME php_windows_wsyslog
  INPUT build/wsyslog.mc
  XDBG_DIR ${CMAKE_CURRENT_BINARY_DIR}
)

add_dependencies(php_windows php_windows_wsyslog)

################################################################################
# Generate cp_enc_map.c.
################################################################################

add_executable(php_windows_encoding_map_generator cp_enc_map_gen.c)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/cp_enc_map.c
  COMMAND php_windows_encoding_map_generator > cp_enc_map.c
  VERBATIM
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "[win32] Generating win32/cp_enc_map.c"
)

target_sources(php_windows PRIVATE cp_enc_map.c)

set_source_files_properties(
  ${CMAKE_CURRENT_SOURCE_DIR}/cp_enc_map.c
  PROPERTIES
    HEADER_FILE_ONLY ON
)

################################################################################
# Configure configuration header.
################################################################################

# Determine major and minor linker version.
block(PROPAGATE PHP_LINKER_MAJOR PHP_LINKER_MINOR)
  if(CMAKE_C_COMPILER_LINKER_VERSION)
    set(version "${CMAKE_C_COMPILER_LINKER_VERSION}")
  else()
    set(version "")
  endif()

  string(REGEX MATCH "^([0-9]+)\\.?" _ "${version}")
  set(PHP_LINKER_MAJOR "${CMAKE_MATCH_1}")
  string(REGEX MATCH "^[0-9]+\\.([0-9]+)\\.?" _ "${version}")
  set(PHP_LINKER_MINOR "${CMAKE_MATCH_1}")

  if(NOT PHP_LINKER_MAJOR)
    set(PHP_LINKER_MAJOR 0)
  endif()

  if(NOT PHP_LINKER_MINOR)
    set(PHP_LINKER_MINOR 0)
  endif()
endblock()

configure_file(cmake/config.h.in config.h @ONLY)

################################################################################
# Configure installation.
################################################################################

install(
  TARGETS php_windows
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}
  FILE_SET generated
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PHP_INCLUDE_PREFIX}
)
