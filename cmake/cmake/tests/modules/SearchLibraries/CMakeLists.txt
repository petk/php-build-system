cmake_minimum_required(VERSION 4.2...4.3)

project(PhpTestSearchLibraries LANGUAGES C)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../../../modules)

include(PHP/SearchLibraries)

php_search_libraries(
  SYMBOL sin
  HEADERS math.h
  LIBRARIES m
  RESULT_VARIABLE PHP_TESTS_HAS_SIN
  LIBRARY_VARIABLE PHP_TESTS_HAS_SIN_LIBRARY
)

if(NOT PHP_TESTS_HAS_SIN)
  message(FATAL_ERROR "sin() not found.")
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  if(NOT PHP_TESTS_HAS_SIN_LIBRARY STREQUAL "")
    message(
      FATAL_ERROR
      "Math library on Windows should not be ${PHP_TESTS_HAS_SIN_LIBRARY}."
    )
  endif()
else()
  if(PHP_TESTS_HAS_SIN_LIBRARY STREQUAL "")
    message(
      FATAL_ERROR
      "Math library on ${CMAKE_SYSTEM_NAME} should be 'm'."
    )
  endif()
endif()
