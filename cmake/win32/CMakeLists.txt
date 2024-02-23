# For Windows only.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

add_library(php_win32 STATIC)
add_library(PHP::win32 ALIAS php_win32)

file(GLOB _php_win32_headers ${CMAKE_CURRENT_SOURCE_DIR}/*.h)

target_sources(
  php_win32
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
    FILE_SET headers_source TYPE HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        ${_php_win32_headers}
    # A separate file set so binary dir can also be created within a source dir.
    FILE_SET headers_binary TYPE HEADERS
      BASE_DIRS "${PHP_BINARY_DIR}"
      FILES
        ${CMAKE_CURRENT_BINARY_DIR}/wsyslog.h
)

target_compile_definitions(
  php_configuration
  INTERFACE
    _MBCS
    _USE_MATH_DEFINES
    PHP_EXPORTS
)

# MS deprecated ANSI stdio and similar functions. Disable warnings. In addition,
# time_t defaults to 64-bit. Ask for 32-bit.
# TODO: Add 32-bit flags.
target_compile_options(
  php_configuration
  INTERFACE
    /wd4996
)

target_link_libraries(php_win32 PRIVATE PHP::configuration)

target_link_libraries(
  php_configuration
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

# Generate wsyslog.h file with message compiler (mc).
find_package(MC)
set_package_properties(
  MC
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to generate win32/wsyslog.h."
)

mc_target(
  NAME php_win32_wsyslog
  INPUT build/wsyslog.mc
  XDBG_DIR ${CMAKE_CURRENT_BINARY_DIR}
)

add_dependencies(php_win32 php_win32_wsyslog)

# Generate cp_enc_map.c.
add_executable(php_win32_encoding_map_generator cp_enc_map_gen.c)

add_custom_target(
  php_win32_encoding_map
  DEPENDS php_win32_encoding_map_generator
  COMMAND php_win32_encoding_map_generator > cp_enc_map.c
  COMMENT "Generating win32/cp_enc_map.c"
)

add_dependencies(php_win32 php_win32_encoding_map)

install(
  TARGETS php_win32
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET headers_source
  FILE_SET headers_binary
)
