include(CMakeDependentOption)

option(EXT_SESSION "Whether to enable the session extension" ON)

cmake_dependent_option(EXT_SESSION_SHARED "Whether to build the session extension as shared object" OFF "EXT_SESSION;NOT BUILD_SHARED_LIBS" OFF)

cmake_dependent_option(EXT_SESSION_MM "SESSION: Include libmm support for session storage" OFF "EXT_SESSION" OFF)

if(EXT_SESSION_MM)
  set(EXT_SESSION_MM_DIR "" CACHE PATH "Path to the MM library")
endif()

if(NOT EXT_SESSION)
  return()
endif()

# Check whether pwrite() works.
include(PHP/CheckPwrite)

# Check whether pread() works.
include(PHP/CheckPread)

if(EXT_SESSION_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "session" ${_library_type})

add_library(ext_session ${_library_type}
  mod_user_class.c
  session.c
  mod_files.c
  mod_mm.c
  mod_user.c
)

target_compile_definitions(ext_session PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set(_ext_session_headers "php_session.h;mod_files.h;mod_user.h")

# The HAVE_SESSION should be used but for BC reasons this is additionally set.
set(HAVE_PHP_SESSION 1 CACHE INTERNAL "Define to 1 if session extension is enabled")

if(EXT_SESSION_MM)
  if(EXT_SESSION_MM_DIR)
    set(MM_ROOT ${EXT_SESSION_MM_DIR})
  endif()

  find_package(MM REQUIRED)

  # The mm library is not thread-safe, and mod_mm.c refuses to compile.
  if(PHP_ZTS)
    message(FATAL_ERROR "Enabling ZTS and libmm cannot be done together.")
  endif()

  target_link_libraries(ext_session PRIVATE MM::MM)

  set(HAVE_LIBMM 1 CACHE INTERNAL "Whether you have libmm")

  list(APPEND _ext_session_headers "${CMAKE_CURRENT_SOURCE_DIR}/mod_mm.h")
endif()

target_sources(
  ext_session
  PUBLIC FILE_SET ext_session_headers
  TYPE HEADERS
  FILES ${_ext_session_headers}
)

install(
  TARGETS ext_session
  FILE_SET ext_session_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/session
)
