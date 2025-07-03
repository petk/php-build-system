#[=============================================================================[
Check and configure compilation options.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(PHP/CheckCompilerFlag)

get_property(enabledLanguages GLOBAL PROPERTY ENABLED_LANGUAGES)

# See https://bugs.php.net/28605.
if(CMAKE_SYSTEM_PROCESSOR MATCHES "^alpha")
  if(CMAKE_C_COMPILER_ID MATCHES "^(.*Clang|GNU)$")
    target_compile_options(php_config INTERFACE $<$<COMPILE_LANGUAGE:C>:-mieee>)
  else()
    target_compile_options(php_config INTERFACE $<$<COMPILE_LANGUAGE:C>:-ieee>)
  endif()
endif()

# Check if GCC has broken strlen() optimization. Early GCC 8 versions shipped
# with a strlen() optimization bug, so it didn't properly handle the
# 'char val[1]' struct hack. Fixed in GCC 8.3. If below check is successful the
# '-fno-optimize-strlen' compiler flag should be added.
# See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=86914
if(
  CMAKE_C_COMPILER_ID STREQUAL "GNU"
  AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 8
  AND CMAKE_C_COMPILER_VERSION VERSION_LESS 8.3
)
  php_check_compiler_flag(C -fno-optimize-strlen PHP_HAS_FNO_OPTIMIZE_STRLEN_C)
  if(PHP_HAS_FNO_OPTIMIZE_STRLEN_C)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C>:-fno-optimize-strlen>
    )
  endif()
endif()

php_check_compiler_flag(C -Wno-sign-compare PHP_HAS_WNO_SIGN_COMPARE_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wno-sign-compare PHP_HAS_WNO_SIGN_COMPARE_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_WNO_SIGN_COMPARE_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wno-sign-compare>
    $<$<AND:$<BOOL:${PHP_HAS_WNO_SIGN_COMPARE_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wno-sign-compare>
)

php_check_compiler_flag(C -Wno-unused-parameter PHP_HAS_WNO_UNUSED_PARAMETER_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wno-unused-parameter PHP_HAS_WNO_UNUSED_PARAMETER_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_WNO_UNUSED_PARAMETER_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wno-unused-parameter>
    $<$<AND:$<BOOL:${PHP_HAS_WNO_UNUSED_PARAMETER_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wno-unused-parameter>
)

php_check_compiler_flag(C -Wextra PHP_HAS_WEXTRA_C)
php_check_compiler_flag(CXX -Wextra PHP_HAS_WEXTRA_CXX)
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_WEXTRA_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wextra>
    $<$<AND:$<BOOL:${PHP_HAS_WEXTRA_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wextra>
)

php_check_compiler_flag(C -Wall PHP_HAS_WALL_C)
php_check_compiler_flag(CXX -Wall PHP_HAS_WALL_CXX)
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  target_compile_options(
    php_config
    BEFORE
    INTERFACE
      $<$<AND:$<BOOL:${PHP_HAS_WALL_C}>,$<CONFIG:Debug>,$<COMPILE_LANGUAGE:ASM,C>>:-Wall>
      $<$<AND:$<BOOL:${PHP_HAS_WALL_CXX}>,$<CONFIG:Debug>,$<COMPILE_LANGUAGE:CXX>>:-Wall>
  )
else()
  target_compile_options(
    php_config
    BEFORE
    INTERFACE
      $<$<AND:$<BOOL:${PHP_HAS_WALL_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wall>
      $<$<AND:$<BOOL:${PHP_HAS_WALL_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wall>
  )
endif()

# Check if compiler supports -Wno-clobbered (only GCC).
php_check_compiler_flag(C -Wno-clobbered PHP_HAS_WNO_CLOBBERED_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wno-clobbered PHP_HAS_WNO_CLOBBERED_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_WNO_CLOBBERED_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wno-clobbered>
    $<$<AND:$<BOOL:${PHP_HAS_WNO_CLOBBERED_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wno-clobbered>
)

# Check for support for implicit fallthrough level 1, also add after previous
# CFLAGS as level 3 is enabled in -Wextra.
php_check_compiler_flag(
  C
  -Wimplicit-fallthrough=1
  PHP_HAS_WIMPLICIT_FALLTHROUGH_1_C
)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(
    CXX
    -Wimplicit-fallthrough=1
    PHP_HAS_WIMPLICIT_FALLTHROUGH_1_CXX
  )
endif()
target_compile_options(
  php_config
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_WIMPLICIT_FALLTHROUGH_1_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wimplicit-fallthrough=1>
    $<$<AND:$<BOOL:${PHP_HAS_WIMPLICIT_FALLTHROUGH_1_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wimplicit-fallthrough=1>
)

php_check_compiler_flag(C -Wduplicated-cond PHP_HAS_WDUPLICATED_COND_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wduplicated-cond PHP_HAS_WDUPLICATED_COND_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_WDUPLICATED_COND_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wduplicated-cond>
    $<$<AND:$<BOOL:${PHP_HAS_WDUPLICATED_COND_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wduplicated-cond>
)

php_check_compiler_flag(C -Wlogical-op PHP_HAS_WLOGICAL_OP_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wlogical-op PHP_HAS_WLOGICAL_OP_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_WLOGICAL_OP_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wlogical-op>
    $<$<AND:$<BOOL:${PHP_HAS_WLOGICAL_OP_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wlogical-op>
)

php_check_compiler_flag(C -Wformat-truncation PHP_HAS_WFORMAT_TRUNCATION_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wformat-truncation PHP_HAS_WFORMAT_TRUNCATION_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_WFORMAT_TRUNCATION_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wformat-truncation>
    $<$<AND:$<BOOL:${PHP_HAS_WFORMAT_TRUNCATION_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wformat-truncation>
)

php_check_compiler_flag(C -Wstrict-prototypes PHP_HAS_WSTRICT_PROTOTYPES_C)
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_WSTRICT_PROTOTYPES_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wstrict-prototypes>
)

php_check_compiler_flag(C -fno-common PHP_HAS_FNO_COMMON_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -fno-common PHP_HAS_FNO_COMMON_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${PHP_HAS_FNO_COMMON_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-fno-common>
    $<$<AND:$<BOOL:${PHP_HAS_FNO_COMMON_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-fno-common>
)

# Explicitly disable floating-point expression contraction, even if already done
# by CMAKE_C_STANDARD. See https://github.com/php/php-src/issues/14140
php_check_compiler_flag(C -ffp-contract=off PHP_HAS_FFP_CONTRACT_OFF_C)
if(PHP_HAS_FFP_CONTRACT_OFF_C)
  target_compile_options(
    php_config
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-ffp-contract=off>
  )
endif()

# Enable inline reader cache.
# https://devblogs.microsoft.com/cppblog/visual-studio-2017-throughput-improvements-and-advice/
if(MSVC)
  target_compile_options(
    php_config
    INTERFACE $<$<COMPILE_LANGUAGE:C,CXX>:/d2FuncCache1>
  )
endif()

################################################################################
# Sanitizer flags.
################################################################################

if(PHP_MEMORY_SANITIZER AND PHP_ADDRESS_SANITIZER)
  message(
    FATAL_ERROR
    "MemorySanitizer and AddressSanitizer are mutually exclusive."
  )
endif()

# Enable memory sanitizer compiler options.
if(PHP_MEMORY_SANITIZER)
  message(CHECK_START "Checking memory sanitizer compiler options")

  block()
    set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

    php_check_compiler_flag(
      C
      "-fsanitize=memory;-fsanitize-memory-track-origins"
      PHP_HAS_MEMORY_SANITIZER_C
    )

    if(CXX IN_LIST enabledLanguages)
      php_check_compiler_flag(
        CXX
        "-fsanitize=memory;-fsanitize-memory-track-origins"
        PHP_HAS_MEMORY_SANITIZER_CXX
      )
    endif()
  endblock()

  if(PHP_HAS_MEMORY_SANITIZER_C OR PHP_HAS_MEMORY_SANITIZER_CXX)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:C,CXX>:-fsanitize=memory;-fsanitize-memory-track-origins>
    )

    target_link_options(
      php_config
      INTERFACE
        $<$<LINK_LANGUAGE:C,CXX>:-fsanitize=memory;-fsanitize-memory-track-origins>
    )

    message(CHECK_PASS "Success")
  else()
    message(CHECK_FAIL "Failed")
    message(FATAL_ERROR "MemorySanitizer is not available.")
  endif()
endif()

# Enable address sanitizer compiler option.
if(PHP_ADDRESS_SANITIZER)
  if(PHP_VALGRIND)
    message(
      FATAL_ERROR
      "Valgrind and address sanitizer are not compatible. Either disable "
      "Valgrind (set 'PHP_VALGRIND' to 'OFF') or disable address sanitizer "
      "(set 'PHP_ADDRESS_SANITIZER' to 'OFF')."
    )
  endif()

  message(CHECK_START "Checking address sanitizer compiler option")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=address")

    php_check_compiler_flag(C -fsanitize=address PHP_HAS_ADDRESS_SANITIZER_C)
    if(CXX IN_LIST enabledLanguages)
      php_check_compiler_flag(CXX -fsanitize=address PHP_HAS_ADDRESS_SANITIZER_CXX)
    endif()
  cmake_pop_check_state()

  if(PHP_HAS_ADDRESS_SANITIZER_C OR PHP_HAS_ADDRESS_SANITIZER_CXX)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=address>
    )

    target_link_options(
      php_config
      INTERFACE
        $<$<LINK_LANGUAGE:C,CXX>:-fsanitize=address>
    )

    target_compile_definitions(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:ZEND_TRACK_ARENA_ALLOC>
    )

    message(CHECK_PASS "Success")
  else()
    message(CHECK_FAIL "Failed")
    message(FATAL_ERROR "AddressSanitizer is not available.")
  endif()
endif()

# Enable the -fsanitize=undefined compiler option.
if(PHP_UNDEFINED_SANITIZER)
  message(CHECK_START "Checking undefined sanitizer compiler options")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=undefined")

    php_check_compiler_flag(
      C
      -fsanitize=undefined
      PHP_HAS_UNDEFINED_SANITIZER_C
    )
    if(CXX IN_LIST enabledLanguages)
      php_check_compiler_flag(
        CXX
        -fsanitize=undefined
        PHP_HAS_UNDEFINED_SANITIZER_CXX
      )
    endif()
  cmake_pop_check_state()

  if(PHP_HAS_UNDEFINED_SANITIZER_C OR PHP_HAS_UNDEFINED_SANITIZER_CXX)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=undefined;-fno-sanitize-recover=undefined>
    )

    target_link_options(
      php_config
      INTERFACE
        $<$<LINK_LANGUAGE:C,CXX>:-fsanitize=undefined;-fno-sanitize-recover=undefined>
    )

    # Disable object-size sanitizer, because it is incompatible with the
    # zend_function union, and this can't be easily fixed.
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LINK_OPTIONS "-fno-sanitize=object-size")

      php_check_compiler_flag(
        C
        -fno-sanitize=object-size
        PHP_HAS_OBJECT_SIZE_SANITIZER_C
      )
      if(CXX IN_LIST enabledLanguages)
        php_check_compiler_flag(
          CXX
          -fno-sanitize=object-size
          PHP_HAS_OBJECT_SIZE_SANITIZER_CXX
        )
      endif()
    cmake_pop_check_state()

    if(PHP_HAS_OBJECT_SIZE_SANITIZER_C OR PHP_HAS_OBJECT_SIZE_SANITIZER_CXX)
      target_compile_options(
        php_config
        INTERFACE
          $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fno-sanitize=object-size>
      )

      target_link_options(
        php_config
        INTERFACE
          $<$<LINK_LANGUAGE:C,CXX>:-fno-sanitize=object-size>
      )
    endif()

    # Clang 17 adds stricter function pointer compatibility checks where pointer
    # args cannot be cast to void*. In that case, set -fno-sanitize=function.
    if(
      NOT DEFINED PHP_HAS_UBSAN_EXITCODE
      AND CMAKE_CROSSCOMPILING
      AND NOT CMAKE_CROSSCOMPILING_EMULATOR
      AND CMAKE_C_COMPILER_ID MATCHES "AppleClang|Clang"
      AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 17
    )
      # When cross-compiling without emulator and using Clang 17 and greater,
      # assume that -fno-sanitize=function needs to be added.
      set(PHP_HAS_UBSAN_EXITCODE 1)
    endif()

    cmake_push_check_state(RESET)
      set(
        CMAKE_REQUIRED_FLAGS
        "-fsanitize=undefined -fno-sanitize-recover=undefined"
      )
      check_source_runs(C [[
        void foo(char *string) { (void)string; }
        int main(void)
        {
          void (*f)(void *) = (void (*)(void *))foo;
          f("foo");
          return 0;
        }
      ]] PHP_HAS_UBSAN)
    cmake_pop_check_state()

    if(NOT PHP_HAS_UBSAN)
      php_check_compiler_flag(
        C
        -fno-sanitize=function
        PHP_HAS_FNO_SANITIZE_FUNCTION_C
      )
      if(CXX IN_LIST enabledLanguages)
        php_check_compiler_flag(
          CXX
          -fno-sanitize=function
          PHP_HAS_FNO_SANITIZE_FUNCTION_CXX
        )
      endif()

      if(PHP_HAS_FNO_SANITIZE_FUNCTION_C)
        target_compile_options(
          php_config
          INTERFACE
            $<$<COMPILE_LANGUAGE:ASM,C>:-fno-sanitize=function>
        )
      endif()

      if(PHP_HAS_FNO_SANITIZE_FUNCTION_CXX)
        target_compile_options(
          php_config
          INTERFACE
            $<$<COMPILE_LANGUAGE:CXX>:-fno-sanitize=function>
        )
      endif()
    endif()

    message(CHECK_PASS "Success")
  else()
    message(CHECK_FAIL "Failed")
    message(FATAL_ERROR "UndefinedBehaviorSanitizer is not available.")
  endif()
endif()

if(PHP_MEMORY_SANITIZER OR PHP_ADDRESS_SANITIZER OR PHP_UNDEFINED_SANITIZER)
  php_check_compiler_flag(
    C
    -fno-omit-frame-pointer
    PHP_HAS_FNO_OMIT_FRAME_POINTER_C
  )
  if(CXX IN_LIST enabledLanguages)
    php_check_compiler_flag(
      CXX
      -fno-omit-frame-pointer
      PHP_HAS_FNO_OMIT_FRAME_POINTER_CXX
    )
  endif()

  if(PHP_HAS_FNO_OMIT_FRAME_POINTER_C)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C>:-fno-omit-frame-pointer>
    )
  endif()

  if(PHP_HAS_FNO_OMIT_FRAME_POINTER_CXX)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:CXX>:-fno-omit-frame-pointer>
    )
  endif()
endif()

# Check if compiler supports the -Wno-typedef-redefinition compile option. PHP
# is written with C99 standard in mind, yet there is a possibility that typedef
# redefinitions could happened in the source code. Since PHP CMake-based build
# system also uses the CMAKE_C_STANDARD_REQUIRED (which adds the -std=...
# compilation option), GCC recent versions usually ignore this and don't emit
# the warnings, however Clang emits warnings that redeclaring typedef is a C11
# feature. Clang has this option to turn off these warnings. As of C11, the
# typedef redefinitions are valid programming, and this can be removed once a
# required CMAKE_C_STANDARD 11 will be used.
if(CMAKE_C_STANDARD EQUAL 99)
  php_check_compiler_flag(
    C
    -Wno-typedef-redefinition
    PHP_HAS_WNO_TYPEDEF_REDEFINITION
  )
  if(PHP_HAS_WNO_TYPEDEF_REDEFINITION)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:C>:-Wno-typedef-redefinition>
    )
  endif()
endif()

################################################################################
# Check linker flags.
################################################################################

include(${CMAKE_CURRENT_LIST_DIR}/checks/CheckSegmentsAlignment.cmake)

include(PHP/VerboseLink)
