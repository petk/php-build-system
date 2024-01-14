# For Windows only.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

add_library(php_win32 STATIC)

add_library(PHP::win32 ALIAS php_win32)

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
    inet.c
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
)

target_compile_definitions(php_win32 PUBLIC PHP_EXPORTS)

target_compile_definitions(
  php_configuration
  INTERFACE
    _MBCS
    _USE_MATH_DEFINES
)

target_link_libraries(php_win32 PRIVATE PHP::configuration)

file(GLOB _php_win32_headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

target_sources(
  php_win32
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      ${_php_win32_headers}
)

install(
  TARGETS php_win32
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
