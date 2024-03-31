include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SESSION "Enable the session extension" ON)

add_feature_info(
  "ext/session"
  EXT_SESSION
  "Sessions support to preserve data across subsequent accesses."
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
  "Include libmm support for session storage (only for non-ZTS build)"
  OFF
  "EXT_SESSION;NOT PHP_THREAD_SAFETY"
  OFF
)

add_feature_info(
  "ext/session with mm"
  EXT_SESSION_MM
  "mm library support for session storage."
)

if(NOT EXT_SESSION)
  return()
endif()

if(EXT_SESSION_SHARED)
  add_library(php_session SHARED)
else()
  add_library(php_session)
endif()

target_sources(
  php_session
  PRIVATE
    mod_files.c
    mod_user_class.c
    mod_user.c
    session.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        mod_files.h
        mod_user.h
        php_session.h
)

target_compile_definitions(php_session PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set_target_properties(
  php_session
  PROPERTIES
    PHP_EXTENSION_DEPENDENCIES "php_hash;php_spl"
)

# Check whether pwrite() works.
include(PHP/CheckPwrite)

# Check whether pread() works.
include(PHP/CheckPread)

set(HAVE_PHP_SESSION 1 CACHE INTERNAL "Define to 1 if session extension is enabled")

if(EXT_SESSION_MM)
  # The mm library is not thread-safe, and mod_mm.c refuses to compile.
  if(PHP_THREAD_SAFETY)
    message(FATAL_ERROR "Thread safety and libmm cannot be done together.")
  endif()

  target_sources(
    php_session
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
  target_link_libraries(php_session PUBLIC MM::MM)

  if(TARGET MM::MM)
    set(HAVE_LIBMM 1 CACHE INTERNAL "Whether you have libmm")
  endif()
endif()

install(
  TARGETS php_session
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/ext/session
)
