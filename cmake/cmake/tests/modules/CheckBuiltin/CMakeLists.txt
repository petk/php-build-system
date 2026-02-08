cmake_minimum_required(VERSION 4.2...4.3)

project(PhpTestCheckBuiltin LANGUAGES C)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../../../modules)

include(PHP/CheckBuiltin)

php_check_builtin(__builtin_clz PHP_TESTS_HAS_BUILTIN_CLZ)

if(NOT DEFINED PHP_TESTS_HAS_BUILTIN_CLZ)
  message(
    FATAL_ERROR
    "The PHP_TESTS_HAS_BUILTIN_CLZ result variable is not defined during the "
    "__builtin_clz check."
  )
endif()
