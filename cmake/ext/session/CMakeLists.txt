include(CMakeDependentOption)

option(EXT_SESSION "Whether to enable the session extension" ON)

cmake_dependent_option(EXT_SESSION_SHARED "Whether to build the session extension as shared object" OFF "EXT_SESSION;NOT BUILD_SHARED_LIBS" OFF)

cmake_dependent_option(EXT_SESSION_MM "SESSION: Include libmm support for session storage" OFF "EXT_SESSION" OFF)

if(NOT EXT_SESSION)
  return()
endif()

# Checks whether pwrite() works.
include(PHPCheckPwrite)

# Checks whether pread() works.
include(PHPCheckPread)

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

set(SESSION_HEADERS "php_session.h;mod_files.h;mod_user.h")

# The HAVE_SESSION should be used but for BC reasons this is additionally set.
set(HAVE_PHP_SESSION 1 CACHE INTERNAL "Define to 1 if session extension is enabled")

if(EXT_SESSION_MM)
  # TODO: Check if EXT_SESSION_MM needs to be manually overrideable path.
  foreach(dir "${EXT_SESSION_MM}" /usr/local /usr)
    if(EXISTS "${dir}/include/mm.h")
      set(MM_DIR "${dir}")
      break()
    endif()
  endforeach()

  if(NOT IS_DIRECTORY "${MM_DIR}")
    message(FATAL_ERROR "Cannot find mm library, please install libmm")
  endif()

  # The mm library is not thread-safe, and mod_mm.c refuses to compile.
  if(PHP_ZTS)
    message(FATAL_ERROR "Enabling ZTS and libmm cannot be done together.")
  endif()

  list(APPEND SESSION_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/mod_mm.h")

  target_include_directories(
    ext_session
    PUBLIC "${MM_DIR}/include"
  )

  # TODO: Add also library path.
  target_link_libraries(ext_session PRIVATE mm)

  set(HAVE_LIBMM 1 CACHE INTERNAL "Whether you have libmm")
endif()

set_target_properties(ext_session PROPERTIES PUBLIC_HEADER "${SESSION_HEADERS}")
