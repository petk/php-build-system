#[=============================================================================[
# PHP/Optimization

Enable interprocedural optimization (IPO/LTO) on all targets, if supported.

This adds linker flag `-flto` if it is supported by the compiler to run standard
link-time optimizer.

It can be also controlled more granular with the
`CMAKE_INTERPROCEDURAL_OPTIMIZATION_<CONFIG>` variables based on the build type.

This module also checks whether IPO/LTO can be enabled based on the PHP
configuration (due to global register variables) and compiler/platform.

https://cmake.org/cmake/help/latest/prop_tgt/INTERPROCEDURAL_OPTIMIZATION.html

## Usage

```cmake
# CMakeLists.txt
include(PHP/Optimization)
```
#]=============================================================================]

include_guard(GLOBAL)

# TODO: Recheck Clang errors as OBJECT libraries doesn't seem to work.
# TODO: Recheck and add PHP_LTO option to docs.

option(PHP_LTO "Build PHP with link time optimization (LTO) if supported")
mark_as_advanced(PHP_LTO)

block(PROPAGATE CMAKE_INTERPROCEDURAL_OPTIMIZATION)
  set(enableIpo ${PHP_LTO})
  set(reason "")

  if(NOT PHP_LTO)
    set(enableIpo FALSE)
    # Disabled.
  elseif(
    CMAKE_C_COMPILER_ID STREQUAL "GNU"
    AND (
      NOT DEFINED ZEND_GLOBAL_REGISTER_VARIABLES
      OR ZEND_GLOBAL_REGISTER_VARIABLES
    )
  )
    # Zend/zend_execute.c uses global register variables and IPO is for now
    # disabled when using GNU C compiler due to a bug:
    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=68384
    set(reason "GCC global register variables")
    set(enableIpo FALSE)
  elseif(CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
    # See: https://gitlab.kitware.com/cmake/cmake/-/issues/25202
    set(reason "AppleClang")
    set(enableIpo FALSE)
  elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang" AND CMAKE_SIZEOF_VOID_P EQUAL 4)
    # On 32-bit Linux machine, this produced undefined references linker errors.
    set(reason "Clang on 32-bit")
    set(enableIpo FALSE)
  endif()

  if(enableIpo)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT supported OUTPUT reason)
    if(NOT supported)
      set(enableIpo FALSE)
      if(NOT reason)
        set(reason "unsupported")
      endif()
    endif()
  endif()

  if(enableIpo)
    message(STATUS "Interprocedural optimization (IPO/LTO) enabled")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
  else()
    if(reason)
      set(reason " (${reason})")
    endif()
    message(STATUS "Interprocedural optimization (IPO/LTO) disabled${reason}")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION FALSE)
  endif()
endblock()
