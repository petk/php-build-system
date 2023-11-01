include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SESSION "Enable the session extension" ON)

add_feature_info("ext/session" EXT_SESSION
  "Adds support for sessions to preserve data across subsequent accesses."
)

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

add_feature_info("ext/session with mm" EXT_SESSION_MM
  "Adds mm library support for session storage. Works only on non-ZTS build."
)

if(NOT EXT_SESSION)
  return()
endif()

if(EXT_SESSION_SHARED)
  add_library(php_session SHARED)
else()
  add_library(php_session)
endif()

target_sources(php_session PRIVATE
  mod_files.c
  mod_mm.c
  mod_user_class.c
  mod_user.c
  session.c
)

target_compile_definitions(php_session PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

# Check whether pwrite() works.
include(PHP/CheckPwrite)

# Check whether pread() works.
include(PHP/CheckPread)

set(_session_headers_files "mod_files.h;mod_user.h;php_session.h")

set(HAVE_PHP_SESSION 1 CACHE INTERNAL "Define to 1 if session extension is enabled")

if(EXT_SESSION_MM)
  # The mm library is not thread-safe, and mod_mm.c refuses to compile.
  if(PHP_ZTS)
    message(FATAL_ERROR "Enabling ZTS and libmm cannot be done together.")
  endif()

  find_package(MM)
  set_package_properties(MM PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the mm session storage."
  )

  # Link with PUBLIC scope if include directories are on non-standard places.
  target_link_libraries(php_session PUBLIC MM::MM)

  if(TARGET MM::MM)
    set(HAVE_LIBMM 1 CACHE INTERNAL "Whether you have libmm")
  endif()

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
