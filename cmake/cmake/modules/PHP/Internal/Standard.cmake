#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It sets the minimum required C standard for PHP.

Load this module in a CMake project with:

  include(PHP/Internal/Standard)

This module sets the minimum required C standard for building and using PHP. It
checks if current C compiler supports the specified C standard and emits an
error if it doesn't. CMake by default already emits error in both cases, when
using CMAKE_C_STANDARD variable with CMAKE_C_STANDARD_REQUIRED or the c_std_XX
compile feature. This module provides a more informational error message for
user to be aware of using a more recent and compatible compiler.
#]=============================================================================]

include_guard(GLOBAL)

include(PHP/CheckCompilerFlag)

block(PROPAGATE CMAKE_C_STANDARD)
  set(standard 99)
  set(unsupported_standards 90)

  if(CMAKE_C_STANDARD_LATEST IN_LIST unsupported_standards)
    message(
      FATAL_ERROR
      "PHP source code requires C${standard} standard or newer. Current C "
      "compiler ${CMAKE_C_COMPILER} supports only C${CMAKE_C_STANDARD_LATEST}."
    )
  endif()

  # Set required C standard and allow parent project to override to newer.
  if(NOT DEFINED CMAKE_C_STANDARD)
    set(CMAKE_C_STANDARD ${standard})
  endif()

  if(CMAKE_C_STANDARD IN_LIST unsupported_standards)
    message(
      WARNING
      "PHP source code requires C${standard} standard or newer. "
      "CMAKE_C_STANDARD has been set to '${standard}'."
    )
    set(CMAKE_C_STANDARD ${standard})
  endif()

  # When building php-src.
  if(TARGET php_config AND TARGET php_extension)
    target_compile_features(php_config INTERFACE c_std_${standard})
    target_compile_features(php_extension INTERFACE c_std_${standard})
  endif()
endblock()

if(NOT DEFINED CMAKE_C_STANDARD_REQUIRED)
  set(CMAKE_C_STANDARD_REQUIRED TRUE)
endif()

# Check if compiler supports the -Wno-typedef-redefinition compile option. PHP
# versions <= 8.4 are written with C99 standard in mind, yet there is a
# possibility that typedef redefinitions could happened in the source code.
# Since PHP CMake-based build system also uses the CMAKE_C_STANDARD_REQUIRED
# (which adds the -std=... compilation option), GCC recent versions usually
# ignore this and don't emit the warnings, however Clang emits warnings that
# redeclaring typedef is a C11 feature. Clang has this option to turn off these
# warnings. As of C11, the typedef redefinitions are valid programming, and this
# can be removed once a required CMAKE_C_STANDARD 11 will be used.
block()
  if(CMAKE_C_STANDARD EQUAL 99)
    php_check_compiler_flag(
      C
      -Wno-typedef-redefinition
      PHP_HAS_WNO_TYPEDEF_REDEFINITION
    )
    if(PHP_HAS_WNO_TYPEDEF_REDEFINITION)
      # Check whether building php-src or a standalone extension.
      if(TARGET php_config)
        set(target "php_config")
      elseif(TARGET PHP::Extension)
        set(target "PHP::Extension")
      endif()

      target_compile_options(
        ${target}
        INTERFACE $<$<COMPILE_LANGUAGE:C>:-Wno-typedef-redefinition>
      )
    endif()
  endif()
endblock()
