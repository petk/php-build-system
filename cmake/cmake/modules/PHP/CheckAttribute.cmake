#[=============================================================================[
# PHP/CheckAttribute

Check if GNU C function or variable attribute is supported by the compiler.

Module exposes the following functions:

```cmake
php_check_function_attribute(<attribute> <result>)
php_check_variable_attribute(<attribute> <result>)
```

* `<attribute>`
  Name of the attribute to check.

* `<result>`
  Cache variable name to store the result of whether the compiler supports the
  attribute `<attribute>`.

Supported function attributes:

* ifunc
* target
* visibility

Supported variable attributes:

* aligned

## Usage

```cmake
# CMakeLists.txt
include(PHP/CheckAttribute)
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

function(_php_check_attribute_get_function_code attribute result)
  if(attribute STREQUAL "ifunc")
    # Clang versions prior to 19 emitted unused function warning for static
    # resolvers: https://github.com/llvm/llvm-project/pull/87130
    set(${result} [[
      int my_foo(void) { return 0; }
      #if defined(__clang__) && (__clang_major__ < 19)
      int (*resolve_foo(void))(void) { return my_foo; }
      #else
      static int (*resolve_foo(void))(void) { return my_foo; }
      #endif
      int foo(void) __attribute__((ifunc("resolve_foo")));
      int main(void) { return 0; }
    ]])
  elseif(attribute STREQUAL "target")
    set(${result} [[
      int bar(void) __attribute__((target("sse2")));
      int main(void) { return 0; }
    ]])
  elseif(attribute STREQUAL "visibility")
    set(${result} [[
      int foo_default(void) __attribute__((visibility("default")));
      int foo_hidden(void) __attribute__((visibility("hidden")));
      int foo_internal(void) __attribute__((visibility("internal")));
      int foo_protected(void) __attribute__((visibility("protected")));
      int main(void) { return 0; }
    ]])
  else()
    set(${result} "")
  endif()

  return(PROPAGATE ${result})
endfunction()

function(_php_check_attribute_get_variable_code attribute result)
  if(attribute STREQUAL "aligned")
    # This could be also simplified to "int foo __attribute__((aligned(32)));".
    set(${result} [[
      unsigned char test[32] __attribute__((aligned(__alignof__(int))));
      int main(void) { return 0; }
    ]])
  else()
    set(${result} "")
  endif()

  return(PROPAGATE ${result})
endfunction()

function(_php_check_attribute what attribute result)
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

  if(NOT what MATCHES "^(function|variable)$")
    message(FATAL_ERROR "Wrong argument passed: ${what}")
  endif()

  # Skip in consecutive configuration phases.
  if(DEFINED ${result})
    return()
  endif()

  message(CHECK_START "Checking for ${what} attribute ${attribute}")

  cmake_push_check_state(RESET)
    # Compilers by default may not treat attribute warnings as errors, so some
    # error flag needs to be set to make the check certain (-Werror=attributes,
    # Clang's -Werror=unknown-attributes, -Werror...). Use the internal CMake
    # compiler-agnostic variable CMAKE_C_COMPILE_OPTIONS_WARNING_AS_ERROR
    # (-Werror or other compiler-based option), if available.
    list(JOIN CMAKE_C_COMPILE_OPTIONS_WARNING_AS_ERROR " " CMAKE_REQUIRED_FLAGS)

    set(CMAKE_REQUIRED_QUIET TRUE)

    cmake_language(CALL _php_check_attribute_get_${what}_code ${attribute} code)

    if(NOT code)
      message(FATAL_ERROR "Unsupported attribute '${attribute}'.")
    endif()

    check_source_compiles(C "${code}" ${result})
  cmake_pop_check_state()

  if(${result})
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endfunction()

function(php_check_function_attribute)
  _php_check_attribute(function ${ARGV})
endfunction()

function(php_check_variable_attribute)
  _php_check_attribute(variable ${ARGV})
endfunction()
