#[=============================================================================[
Set Zend Engine version variables from the php-src/Zend/*.h header files.

Variables:

* PHP_ZEND_VERSION_EXTENSION_API_NO
* PHP_ZEND_VERSION_LABEL
* PHP_ZEND_VERSION_MODULE_API_NO
* PHP_ZEND_VERSION
#]=============================================================================]

include_guard(GLOBAL)

# Set Zend Engine version variables.
block(PROPAGATE PHP_ZEND_VERSION PHP_ZEND_VERSION_LABEL)
  file(
    STRINGS
    zend.h
    _
    REGEX "^[ \t]*#[ \t]*define[ \t]+ZEND_VERSION[ \t]+\"([0-9.]+)([^\"]*)"
  )
  set(PHP_ZEND_VERSION "${CMAKE_MATCH_1}")
  set(PHP_ZEND_VERSION_LABEL "${CMAKE_MATCH_2}")
endblock()

# This is automatically executed with the project(Zend...) invocation.
function(_zend_version_post_project)
  if(DEFINED PHP_ZEND_VERSION_MODULE_API_NO)
    return()
  endif()

  # Append extra version label suffix to version.
  string(APPEND PHP_ZEND_VERSION "${PHP_ZEND_VERSION_LABEL}")
  message(STATUS "Zend Engine version: ${PHP_ZEND_VERSION}")

  # Get extensions API number.
  file(
    STRINGS
    zend_extensions.h
    _
    REGEX "^[ \t]*#[ \t]*define[ \t]+ZEND_EXTENSION_API_NO[ \t]+([0-9]+)"
  )
  set(PHP_ZEND_VERSION_EXTENSION_API_NO "${CMAKE_MATCH_1}")

  # Get modules API number.
  file(
    STRINGS
    zend_modules.h
    _
    REGEX "^[ \t]*#[ \t]*define[ \t]+ZEND_MODULE_API_NO[ \t]+([0-9]+)"
  )
  set(PHP_ZEND_VERSION_MODULE_API_NO "${CMAKE_MATCH_1}")

  return(
    PROPAGATE
      PHP_ZEND_VERSION
      PHP_ZEND_VERSION_EXTENSION_API_NO
      PHP_ZEND_VERSION_MODULE_API_NO
  )
endfunction()
variable_watch(PHP_ZEND_DESCRIPTION _zend_version_post_project)
