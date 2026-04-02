cmake_minimum_required(VERSION 4.3...4.4)

project(PhpTestCheckBuiltin LANGUAGES C)

include(PHP/CheckBuiltin)

php_check_builtin(__builtin_clz PHP_TESTS_HAS_BUILTIN_CLZ)

if(NOT DEFINED PHP_TESTS_HAS_BUILTIN_CLZ)
  message(
    FATAL_ERROR
    "The PHP_TESTS_HAS_BUILTIN_CLZ result variable is not defined during the "
    "__builtin_clz check."
  )
endif()
