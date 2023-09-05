#[=============================================================================[
PHP module that reads the PHP version from the configure.ac file and sets
PHP version variables.
]=============================================================================]#

file(READ "${CMAKE_SOURCE_DIR}/configure.ac" _content)

string(REGEX MATCH "AC_INIT\\(\\[PHP\\],\\[([0-9])\\.([0-9]+)\\.([0-9]*)(-dev)?.*" _ "${_content}")

# Set PHP version variables.
set(PHP_VERSION_MAJOR ${CMAKE_MATCH_1})
set(PHP_VERSION_MINOR ${CMAKE_MATCH_2})
set(PHP_VERSION_PATCH ${CMAKE_MATCH_3})
set(PHP_VERSION_LABEL ${CMAKE_MATCH_4} CACHE STRING "Extra PHP version label suffix, e.g. '-dev', 'rc1', '-acme'")

string(CONCAT PHP_VERSION "${PHP_VERSION_MAJOR}" "." "${PHP_VERSION_MINOR}" "." "${PHP_VERSION_PATCH}" "${PHP_VERSION_LABEL}")

math(EXPR PHP_VERSION_ID "${PHP_VERSION_MAJOR} * 10000 + ${PHP_VERSION_MINOR} * 100 + ${PHP_VERSION_PATCH}")
