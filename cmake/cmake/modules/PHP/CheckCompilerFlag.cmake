#[=============================================================================[
Check whether the compiler supports given compile option.

CMake's CheckCompilerFlag module and its check_compiler_flag() macro at time of
writing don't support some common edge cases, such as detecting GCC's '-Wno-'
options and similar. This module aims to bypass these issues but still providing
similar functionality on top of CMake's CheckCompilerFlag.

Module exposes the following function:

  php_check_compiler_flag(<lang> <flag> <result_var>)

    Check that the <flag> is accepted by the <lang> compiler without a
    diagnostic. The result is stored in an internal cache entry named
    <result_var>. The language of the check (<lang>) can be C or CXX.
]=============================================================================]#

include(CheckCompilerFlag)

function(php_check_compiler_flag lang flag result)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed # prefix
    ""     # options
    ""     # one-value keywords
    ""     # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARGC EQUAL 3)
    message(FATAL_ERROR "Missing arguments")
  endif()

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT lang MATCHES "^(C|CXX)$")
    message(FATAL_ERROR "Wrong argument passed: ${lang}")
  endif()

  # When checking the '-Wno-...' compile options, GCC by default accepts them
  # without issuing any diagnostic messages. When using GCC compiler solution is
  # to revert these checks into checking for the -W... compile option instead.
  # This behavior was introduced since GCC 4.4:
  # https://gcc.gnu.org/gcc-4.4/changes.html
  if(
    CMAKE_${lang}_COMPILER_ID STREQUAL "GNU"
    AND CMAKE_${lang}_COMPILER_VERSION VERSION_GREATER_EQUAL 4.4
    AND flag MATCHES "^-Wno-"
    AND NOT flag MATCHES "^-Wno-error(=|$)"
  )
    string(REGEX REPLACE "^-Wno-" "-W" flag ${flag})
  endif()

  check_compiler_flag(${lang} ${flag} ${result})
endfunction()
