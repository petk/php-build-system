#[=============================================================================[
# PHP/CheckCompilerFlag

Check whether the compiler supports given compile option.

CMake's `CheckCompilerFlag` module and its `check_compiler_flag()` macro, at the
time of writing, do not support certain edge cases for certain compilers. This
module aims to address these issues to make checking compile options easier and
more intuitive, while still providing similar functionality on top of CMake's
`CheckCompilerFlag`.

Bypasses:

* Compile options to disable warnings (`-Wno-*`)

  When checking the `-Wno-*` flags, some compilers (GCC, Oracle Developer Studio
  compiler, and most likely some others) don't issue any diagnostic message when
  encountering unsupported `-Wno-*` flag. This modules checks for their opposite
  compile option instead (`-W*`). For example, the silent `-Wno-*` compile flags
  behavior was introduced since GCC 4.4:
  https://gcc.gnu.org/gcc-4.4/changes.html

  See: https://gitlab.kitware.com/cmake/cmake/-/issues/26228

Module exposes the following function:

```cmake
php_check_compiler_flag(<lang> <flag> <result_var>)
```

Check that the <flag> is accepted by the <lang> compiler without issuing any
diagnostic message. The result is stored in an internal cache entry named
`<result_var>`. The language `<lang>` can be one of the supported languages by
the CMake's `CheckCompilerFlag` module.

For example:

```cmake
include(PHP/CheckCompilerFlag)

php_check_compiler_flag(C -Wno-clobbered PHP_HAVE_WNO_CLOBBERED)
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckCompilerFlag)
include(CMakePushCheckState)

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
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARGC EQUAL 3)
    message(FATAL_ERROR "Missing arguments.")
  endif()

  # Skip in consecutive configuration phases.
  if(DEFINED ${result})
    return()
  endif()

  if(NOT CMAKE_REQUIRED_QUIET)
    message(CHECK_START "Checking whether the ${lang} compiler accepts ${flag}")
  endif()

  cmake_push_check_state()
    set(CMAKE_REQUIRED_QUIET TRUE)

    # Bypass the '-Wno-*' compile options for all compilers except those known
    # to emit diagnostic messages for unknown -Wno-* flags.
    if(
      NOT CMAKE_${lang}_COMPILER_ID MATCHES "^(AppleClang|Clang|MSVC)$"
      AND flag MATCHES "^-Wno-"
      # Exclude the '-Wno-error' and '-Wno-attributes=*' flags.
      AND NOT flag MATCHES "^-Wno-error(=|$)|^-Wno-attributes="
    )
      string(REGEX REPLACE "^-Wno-" "-W" flag ${flag})
    endif()

    # Append -Wunknown-warning-option option if compiler supports it (Clang or
    # similar) and was by any chance configured with -Wno-unknown-warning-option
    # (via environment CFLAGS or CMAKE_C_FLAGS).
    if(flag MATCHES "^-W")
      check_compiler_flag(
        ${lang}
        -Wunknown-warning-option
        _php_check_compiler_flag_${lang}_unknown_warning_option
      )

      if(_php_check_compiler_flag_${lang}_unknown_warning_option)
        string(APPEND CMAKE_REQUIRED_FLAGS " -Wunknown-warning-option")
      endif()
    endif()

    check_compiler_flag(${lang} ${flag} ${result})
  cmake_pop_check_state()

  if(NOT CMAKE_REQUIRED_QUIET)
    if(${result})
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()
endfunction()
