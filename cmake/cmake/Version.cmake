#[=============================================================================[
Set PHP version variables.

PHP version is read from the php-src configure.ac file, and PHP_VERSION_API
number from the php-src main/php.h header file.

Variables:

* PHP_API_VERSION
* PHP_VERSION
* PHP_VERSION_LABEL
#]=============================================================================]

include_guard(GLOBAL)

# Set the PHP_VERSION_* variables from configure.ac.
block(PROPAGATE PHP_VERSION)
  file(STRINGS configure.ac _ REGEX "^AC_INIT.+PHP\\],\\[([0-9.]+)([^]]*)")
  set(PHP_VERSION "${CMAKE_MATCH_1}")
  set(
    CACHE{PHP_VERSION_LABEL}
    TYPE STRING
    HELP "Extra PHP version label suffix, e.g. '-dev', 'rc1', '-acme'"
    VALUE "${CMAKE_MATCH_2}"
  )
  mark_as_advanced(PHP_VERSION_LABEL)
endblock()

# This is automatically executed with the project(PHP...) invocation.
function(_php_version_post_project)
  if(DEFINED PHP_VERSION_ID)
    return()
  endif()

  # Append extra version label suffix to version.
  string(APPEND PHP_VERSION "${PHP_VERSION_LABEL}")
  message(STATUS "PHP version: ${PHP_VERSION}")

  # Set PHP version ID.
  math(
    EXPR
    PHP_VERSION_ID
    "${PHP_VERSION_MAJOR} * 10000 \
    + ${PHP_VERSION_MINOR} * 100 \
    + ${PHP_VERSION_PATCH}"
  )

  # Get PHP API version.
  file(
    STRINGS
    main/php.h
    _
    REGEX "^[ \t]*#[ \t]*define[ \t]+PHP_API_VERSION[ \t]+([0-9]+)"
  )
  set(PHP_API_VERSION "${CMAKE_MATCH_1}")

  return(PROPAGATE PHP_VERSION PHP_VERSION_ID PHP_API_VERSION)
endfunction()
variable_watch(PHP_HOMEPAGE_URL _php_version_post_project)
