#[=============================================================================[
# The session extension

Configure the `session` extension.

This extension provides support for sessions to preserve data across subsequent
accesses.

## PHP_EXT_SESSION

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_SESSION_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## PHP_EXT_SESSION_MM

* Default: `OFF`
* Values: `ON|OFF`

Include libmm support for session storage (only for non-ZTS build).
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionSession
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_SESSION "Enable the session extension" ON)

add_feature_info(
  "ext/session"
  PHP_EXT_SESSION
  "preservable data across subsequent accesses"
)

cmake_dependent_option(
  PHP_EXT_SESSION_SHARED
  "Build the session extension as a shared library"
  OFF
  "PHP_EXT_SESSION;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  PHP_EXT_SESSION_MM
  "Include libmm support for session storage (only for non-ZTS build)"
  OFF
  "PHP_EXT_SESSION;NOT PHP_THREAD_SAFETY"
  OFF
)
mark_as_advanced(PHP_EXT_SESSION_MM)
add_feature_info(
  "ext/session mm"
  PHP_EXT_SESSION_MM
  "session storage using mm library"
)

if(NOT PHP_EXT_SESSION)
  return()
endif()

if(PHP_EXT_SESSION_SHARED)
  add_library(php_ext_session SHARED)
else()
  add_library(php_ext_session)
endif()

target_sources(
  php_ext_session
  PRIVATE
    mod_files.c
    mod_user_class.c
    mod_user.c
    session.c
    session.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        mod_files.h
        mod_user.h
        php_session.h
)

target_compile_definitions(
  php_ext_session
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

add_dependencies(
  php_ext_session
  php_ext_date
  php_ext_random
  php_ext_spl # Optional dependency for spl autoloading https://bugs.php.net/53141
)

# Check whether pread() and pwrite() work.
include(cmake/CheckPreadPwrite.cmake)

if(PHP_EXT_SESSION_MM)
  if(PHP_THREAD_SAFETY)
    message(
      FATAL_ERROR
      "Thread safety and libmm cannot be used together. The mm library (libmm) "
      "is not thread-safe, and mod_mm_c refuses to compile. Either disable the "
      "thread safety by setting PHP_THREAD_SAFETY to 'OFF', or disable libmm "
      "by setting 'PHP_EXT_SESSION_MM' to 'OFF'."
    )
  endif()

  target_sources(
    php_ext_session
    PRIVATE
      mod_mm.c
    PUBLIC
      FILE_SET HEADERS
        FILES
          mod_mm.h
  )

  find_package(MM)
  set_package_properties(
    MM
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the mm session storage."
  )

  # Link with PUBLIC scope if include directories are on non-standard places.
  target_link_libraries(php_ext_session PUBLIC MM::MM)

  if(TARGET MM::MM)
    set(HAVE_LIBMM TRUE)
  endif()
endif()

set(HAVE_PHP_SESSION TRUE)

configure_file(cmake/config.h.in config.h)
