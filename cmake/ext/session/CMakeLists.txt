include(CMakeDependentOption)

option(EXT_SESSION "Enable the session extension" ON)

cmake_dependent_option(
  EXT_SESSION_SHARED
  "Build the session extension as a shared library"
  OFF
  "EXT_SESSION;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_SESSION_MM
  "Include libmm support for session storage"
  OFF
  "EXT_SESSION"
  OFF
)

if(NOT EXT_SESSION)
  return()
endif()

# Check whether pwrite() works.
include(PHP/CheckPwrite)

# Check whether pread() works.
include(PHP/CheckPread)

if(EXT_SESSION_SHARED)
  set(_type "SHARED")
endif()

add_library(php_session ${_type}
  mod_user_class.c
  session.c
  mod_files.c
  mod_mm.c
  mod_user.c
)

target_compile_definitions(php_session PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set(_session_headers_files "php_session.h;mod_files.h;mod_user.h")

# The HAVE_SESSION should be used but for BC reasons this is additionally set.
set(HAVE_PHP_SESSION 1 CACHE INTERNAL "Define to 1 if session extension is enabled")

if(EXT_SESSION_MM)
  # The mm library is not thread-safe, and mod_mm.c refuses to compile.
  if(PHP_ZTS)
    message(FATAL_ERROR "Enabling ZTS and libmm cannot be done together.")
  endif()

  find_package(MM REQUIRED)

  # Link with PUBLIC scope if include directories are on non-standard places.
  target_link_libraries(php_session PUBLIC MM::MM)

  set(HAVE_LIBMM 1 CACHE INTERNAL "Whether you have libmm")

  list(APPEND _session_headers_files "${CMAKE_CURRENT_SOURCE_DIR}/mod_mm.h")
endif()

target_sources(
  php_session
  PUBLIC FILE_SET session_headers
  TYPE HEADERS
  FILES ${_session_headers_files}
)

install(
  TARGETS php_session
  FILE_SET session_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/session
)
