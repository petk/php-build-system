#[=============================================================================[
This is an internal module and is not intended for direct usage inside projects.
It sets the minimum required C standard for PHP.

Load this module in a CMake project with:

  include(PHP/Internal/Standard)

This module sets the minimum required C standard for building and using PHP. It
verifies that the current C compiler supports the specified C standard and emits
an error if it does not. CMake already emits error, when using the
CMAKE_C_STANDARD variable together with CMAKE_C_STANDARD_REQUIRED, or when
specifying the c_std_XX compile feature. However, this module provides a more
informative and user-friendly error message, clearly indicating that a more
recent and compatible compiler is required.
#]=============================================================================]

include_guard(GLOBAL)

include(PHP/CheckCompilerFlag)

block(PROPAGATE CMAKE_C_STANDARD)
  set(standard 99)
  set(unsupported_standards 90)

  if(CMAKE_C_STANDARD_LATEST IN_LIST unsupported_standards)
    set(compiler "C compiler \"${CMAKE_C_COMPILER_ID}\"")

    if(CMAKE_C_COMPILER_VERSION)
      string(APPEND compiler " version ${CMAKE_C_COMPILER_VERSION}")
    endif()

    string(APPEND compiler " (${CMAKE_C_COMPILER})")

    message(
      FATAL_ERROR
      "PHP requires the language dialect \"C${standard}\". The current "
      "${compiler} does not support this, or CMake version ${CMAKE_VERSION} "
      "does not know the flags to enable it (the latest supported and known "
      "standard is \"C${CMAKE_C_STANDARD_LATEST}\"). Please, update the "
      "compiler."
    )
  endif()

  # Set required C standard and allow parent project to override to newer.
  if(NOT DEFINED CMAKE_C_STANDARD)
    set(CMAKE_C_STANDARD ${standard})
  endif()

  if(CMAKE_C_STANDARD IN_LIST unsupported_standards)
    message(
      WARNING
      "PHP requires \"C${standard}\" standard or newer. CMAKE_C_STANDARD has "
      "been set to '${standard}'."
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
      else()
        set(target "")
      endif()

      if(target)
        target_compile_options(
          ${target}
          INTERFACE $<$<COMPILE_LANGUAGE:C>:-Wno-typedef-redefinition>
        )
      endif()
    endif()
  endif()
endblock()
