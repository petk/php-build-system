#[=============================================================================[
Read the PHP version from the configure.ac file and set PHP version variables.
]=============================================================================]#

file(READ "${CMAKE_CURRENT_LIST_DIR}/../../../configure.ac" _php_content)

string(
  REGEX MATCH
  "AC_INIT\\(\\[PHP\\],\\[([0-9]+)\\.([0-9]+)\\.([0-9]+)([A-Za-z0-9\\-]*)"
  _
  "${_php_content}"
)

unset(_php_content)

set(PHP_VERSION_MAJOR ${CMAKE_MATCH_1})
set(PHP_VERSION_MINOR ${CMAKE_MATCH_2})
set(PHP_VERSION_PATCH ${CMAKE_MATCH_3})
set(
  PHP_VERSION_LABEL "${CMAKE_MATCH_4}"
  CACHE STRING "Extra PHP version label suffix, e.g. '-dev', 'rc1', '-acme'"
)

math(
  EXPR PHP_VERSION_ID
  "${PHP_VERSION_MAJOR} * 10000 + ${PHP_VERSION_MINOR} * 100 + ${PHP_VERSION_PATCH}"
)

message(
  STATUS
  "PHP version: "
  "${PHP_VERSION_MAJOR}."
  "${PHP_VERSION_MINOR}."
  "${PHP_VERSION_PATCH}"
  "${PHP_VERSION_LABEL}"
)
