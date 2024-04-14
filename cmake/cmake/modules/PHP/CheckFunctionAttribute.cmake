#[=============================================================================[
Check if GNU C function attribute is supported by the compiler.

Module exposes the following function:

  php_check_function_attribute(<attribute-name> <result>)

    <attribute-name>
      Name of the function attribute to check.
    <result>
      Name of the cache variable to store the check result of whether function
      attribute <attribute-name> is supported by the compiler.

Supported attributes:

  ifunc
  target
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

function(_php_check_function_attribute_code attribute)
  if(attribute STREQUAL "")
    set(code "")
  elseif(attribute STREQUAL "ifunc")
    set(code [[
      int my_foo(void) { return 0; }
      static int (*resolve_foo(void))(void) { return my_foo; }
      int foo(void) __attribute__((ifunc("resolve_foo")));

      int main(void) {
        return 0;
      }
    ]])
  elseif(attribute STREQUAL "target")
    set(code [[
      int bar(void) __attribute__((target("sse2")));

      int main(void) {
        return 0;
      }
    ]])
  endif()

  return(PROPAGATE code)
endfunction()

function(php_check_function_attribute attribute result)
  message(CHECK_START "Checking for __attribute__(${attribute})")

  cmake_push_check_state(RESET)
    # By default, compiler doesn't treat warnings as errors, so flag needs to be
    # set for the time of the test to make the check useful.
    if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
      set(CMAKE_REQUIRED_FLAGS "/WX")
    else()
      set(CMAKE_REQUIRED_FLAGS "-Werror")
    endif()

    set(CMAKE_REQUIRED_QUIET TRUE)

    _php_check_function_attribute_code(${attribute})

    check_source_compiles(C "${code}" ${result})
  cmake_pop_check_state()

  if(${result})
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endfunction()
