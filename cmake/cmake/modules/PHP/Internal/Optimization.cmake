#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It provides command to check whether interprocedural optimization (IPO/LTO) can
be enabled.

Load this module in a CMake project with:

  include(PHP/Internal/Optimization)

Interprocedural optimization uses linker flags such as `-flto` if it is
supported by the compiler to run standard link-time optimizer.

Interprocedural optimization can be also controlled more granular with the
CMAKE_INTERPROCEDURAL_OPTIMIZATION_<CONFIG> variables based on the build type.

This module also checks whether IPO/LTO can be enabled based on the PHP
configuration (due to global register variables) and compiler/platform.

https://cmake.org/cmake/help/latest/prop_tgt/INTERPROCEDURAL_OPTIMIZATION.html

Commands

This module provides the following commands:

php_optimization()

  Checks whether interprocedural optimization is supported:

    php_optimization(<result-var>)

    The arguments are:

      <result-var>
        Name of a variable in which the boolean result is stored.
#]=============================================================================]

include_guard(GLOBAL)

# Check whether interprocedural optimization can be enabled for php-src.
function(_php_optimization_check_php_src)
  cmake_parse_arguments(PARSE_ARGV 0 parsed "" "RESULT;REASON" "")

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT DEFINED parsed_RESULT)
    message(FATAL_ERROR "The RESULT argument is missing.")
  endif()

  if(NOT DEFINED parsed_REASON)
    message(FATAL_ERROR "The REASON argument is missing.")
  endif()

  set(${parsed_RESULT} TRUE)
  set(${parsed_REASON} "")

  if(
    CMAKE_C_COMPILER_ID STREQUAL "GNU"
    AND
      (
        NOT DEFINED PHP_ZEND_GLOBAL_REGISTER_VARIABLES
        OR PHP_ZEND_GLOBAL_REGISTER_VARIABLES
      )
  )
    # Zend/zend_execute.c uses global register variables and IPO is for now
    # disabled when using GNU C compiler due to a bug:
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=68384
    set(${parsed_REASON} "GCC global register variables")
    set(${parsed_RESULT} FALSE)
  elseif(CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
    # See: https://gitlab.kitware.com/cmake/cmake/-/issues/25202
    set(${parsed_REASON} "AppleClang")
    set(${parsed_RESULT} FALSE)
  elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_SIZEOF_VOID_P EQUAL 4)
    # On 32-bit Linux machine, this produced undefined references linker errors.
    set(${parsed_REASON} "Clang on 32-bit")
    set(${parsed_RESULT} FALSE)
  endif()

  return(PROPAGATE ${parsed_RESULT} ${parsed_REASON})
endfunction()

function(php_optimization)
  if(DEFINED PHP_IS_TOP_LEVEL)
    _php_optimization_check_php_src(RESULT enable_ipo REASON reason)
  else()
    set(enable_ipo TRUE)
    set(reason "")
  endif()

  if(enable_ipo)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT supported OUTPUT reason)
    if(NOT supported)
      set(enable_ipo FALSE)

      if(NOT reason)
        set(reason "unsupported")
      endif()
    endif()
  endif()

  if(enable_ipo)
    message(STATUS "Interprocedural optimization (IPO/LTO) enabled")
    set(${ARGV0} TRUE)
  else()
    if(reason)
      set(reason " (${reason})")
    endif()

    message(STATUS "Interprocedural optimization (IPO/LTO) disabled${reason}")
    set(${ARGV0} FALSE)
  endif()

  return(PROPAGATE ${ARGV0})
endfunction()
