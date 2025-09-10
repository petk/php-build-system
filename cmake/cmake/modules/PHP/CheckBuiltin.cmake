#[=============================================================================[
# PHP/CheckBuiltin

This module provides a command to check whether the C compiler supports the
given built-in function `__builtin_*()`.

Load this module in a CMake project with:

```cmake
include(PHP/CheckBuiltin)
```

## Commands

This module provides the following command:

### `php_check_builtin()`

Checks whether the C compiler supports the given built-in function:

```cmake
php_check_builtin(<builtin> <result-var>)
```

#### The arguments are:

* `<builtin>`

  Name of the builtin to be checked.

* `<result-var>`

  Name of an internal cache variable to store the boolean result of the check.

When C compiler is `MSVC`, all builtins are reported as not supported.

## Examples

Basic usage:

```cmake
# CMakeLists.txt

include(PHP/CheckBuiltin)

php_check_builtin(__builtin_clz PHP_HAVE_BUILTIN_CLZ)
```
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

function(php_check_builtin builtin result)
  # Skip in consecutive configuration phases.
  if(DEFINED ${result})
    return()
  endif()

  message(CHECK_START "Checking for ${builtin}")

  if(builtin STREQUAL "__builtin_clz")
    set(call "return __builtin_clz(1) ? 1 : 0;")
  elseif(builtin STREQUAL "__builtin_clzl")
    set(call "return __builtin_clzl(1) ? 1 : 0;")
  elseif(builtin STREQUAL "__builtin_clzll")
    set(call "return __builtin_clzll(1) ? 1 : 0;")
  elseif(builtin STREQUAL "__builtin_cpu_init")
    set(call "__builtin_cpu_init();")
  elseif(builtin STREQUAL "__builtin_cpu_supports")
    set(call "return __builtin_cpu_supports(\"sse\") ? 1 : 0;")
  elseif(builtin STREQUAL "__builtin_ctzl")
    set(call "return __builtin_ctzl(2L) ? 1 : 0;")
  elseif(builtin STREQUAL "__builtin_ctzll")
    set(call "return __builtin_ctzll(2LL) ? 1 : 0;")
  elseif(builtin STREQUAL "__builtin_expect")
    set(call "return __builtin_expect(1,1) ? 1 : 0;")
  elseif(builtin STREQUAL "__builtin_frame_address")
    set(call "return __builtin_frame_address(0) != (void*)0;")
  elseif(builtin STREQUAL "__builtin_saddl_overflow")
    set(call "long tmpvar; return __builtin_saddl_overflow(3, 7, &tmpvar);")
  elseif(builtin STREQUAL "__builtin_saddll_overflow")
    set(call "long long tmpvar; return __builtin_saddll_overflow(3, 7, &tmpvar);")
  elseif(builtin STREQUAL "__builtin_smull_overflow")
    set(call "long tmpvar; return __builtin_smull_overflow(3, 7, &tmpvar);")
  elseif(builtin STREQUAL "__builtin_smulll_overflow")
    set(call "long long tmpvar; return __builtin_smulll_overflow(3, 7, &tmpvar);")
  elseif(builtin STREQUAL "__builtin_ssubl_overflow")
    set(call "long tmpvar; return __builtin_ssubl_overflow(3, 7, &tmpvar);")
  elseif(builtin STREQUAL "__builtin_ssubll_overflow")
    set(call "long long tmpvar; return __builtin_ssubll_overflow(3, 7, &tmpvar);")
  elseif(builtin STREQUAL "__builtin_unreachable")
    set(call "__builtin_unreachable();")
  elseif(builtin STREQUAL "__builtin_usub_overflow")
    set(call "unsigned int tmpvar; return __builtin_usub_overflow(3, 7, &tmpvar);")
  else()
    message(WARNING "PHP/CheckBuiltin: ${builtin} might not be supported.")
    set(call "${builtin}();")
  endif()

  if(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    set(${result} FALSE CACHE INTERNAL "Test ${result}")
  endif()

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C "
      int main(void)
      {
        ${call}

        return 0;
      }
    " ${result})
  cmake_pop_check_state()

  if(${result})
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endfunction()
