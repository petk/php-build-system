include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SESSION "Enable the session extension" ON)

add_feature_info(
  "ext/session"
  EXT_SESSION
  "Sessions support to preserve data across subsequent accesses"
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
  "mm library support for session storage"
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

target_compile_definitions(
  php_session
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

# For spl autoloading https://bugs.php.net/53141
if(TARGET php_spl)
  add_dependencies(php_session php_spl)
endif()

add_dependencies(php_session php_date php_random)

# Check whether pread() and pwrite() work.
include(PHP/CheckPreadPwrite)

set(
  HAVE_PHP_SESSION 1
  CACHE INTERNAL "Whether the session extension is available."
)

if(EXT_SESSION_MM)
  if(PHP_THREAD_SAFETY)
    message(
      FATAL_ERROR
      "Thread safety and libmm cannot be used together. The mm library (libmm) "
      "is not thread-safe, and mod_mm_c refuses to compile. Either disable the "
      "thread safety by setting PHP_THREAD_SAFETY to 'OFF', or disable libmm "
      "by setting EXT_SESSION_MM to 'OFF'."
    )
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
    set(HAVE_LIBMM 1 CACHE INTERNAL "Whether system has the libmm library.")
  endif()
endif()
