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

# Check for broken GCC optimize-strlen.
include(PHP/CheckBrokenGccStrlenOpt)
if(PHP_HAVE_BROKEN_OPTIMIZE_STRLEN)
  php_check_compiler_flag(C -fno-optimize-strlen HAVE_FNO_OPTIMIZE_STRLEN_C)
  if(HAVE_FNO_OPTIMIZE_STRLEN_C)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C>:-fno-optimize-strlen>
    )
  endif()
endif()

php_check_compiler_flag(C -Wno-sign-compare HAVE_WNO_SIGN_COMPARE_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wno-sign-compare HAVE_WNO_SIGN_COMPARE_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${HAVE_WNO_SIGN_COMPARE_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wno-sign-compare>
    $<$<AND:$<BOOL:${HAVE_WNO_SIGN_COMPARE_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wno-sign-compare>
)

php_check_compiler_flag(C -Wno-unused-parameter HAVE_WNO_UNUSED_PARAMETER_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wno-unused-parameter HAVE_WNO_UNUSED_PARAMETER_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${HAVE_WNO_UNUSED_PARAMETER_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wno-unused-parameter>
    $<$<AND:$<BOOL:${HAVE_WNO_UNUSED_PARAMETER_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wno-unused-parameter>
)

if(MSVC)
  target_compile_options(
    php_config
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:/W4>
  )
else()
  target_compile_options(
    php_config
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-Wall;-Wextra>
  )
endif()

# Check if compiler supports -Wno-clobbered (only GCC).
php_check_compiler_flag(C -Wno-clobbered HAVE_WNO_CLOBBERED_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wno-clobbered HAVE_WNO_CLOBBERED_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${HAVE_WNO_CLOBBERED_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wno-clobbered>
    $<$<AND:$<BOOL:${HAVE_WNO_CLOBBERED_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wno-clobbered>
)

# Check for support for implicit fallthrough level 1, also add after previous
# CFLAGS as level 3 is enabled in -Wextra.
php_check_compiler_flag(
  C
  -Wimplicit-fallthrough=1
  HAVE_WIMPLICIT_FALLTHROUGH_1_C
)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(
    CXX
    -Wimplicit-fallthrough=1
    HAVE_WIMPLICIT_FALLTHROUGH_1_CXX
  )
endif()
target_compile_options(
  php_config
  INTERFACE
    $<$<AND:$<BOOL:${HAVE_WIMPLICIT_FALLTHROUGH_1_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wimplicit-fallthrough=1>
    $<$<AND:$<BOOL:${HAVE_WIMPLICIT_FALLTHROUGH_1_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wimplicit-fallthrough=1>
)

php_check_compiler_flag(C -Wduplicated-cond HAVE_WDUPLICATED_COND_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wduplicated-cond HAVE_WDUPLICATED_COND_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${HAVE_WDUPLICATED_COND_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wduplicated-cond>
    $<$<AND:$<BOOL:${HAVE_WDUPLICATED_COND_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wduplicated-cond>
)

php_check_compiler_flag(C -Wlogical-op HAVE_WLOGICAL_OP_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wlogical-op HAVE_WLOGICAL_OP_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${HAVE_WLOGICAL_OP_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wlogical-op>
    $<$<AND:$<BOOL:${HAVE_WLOGICAL_OP_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wlogical-op>
)

php_check_compiler_flag(C -Wformat-truncation HAVE_WFORMAT_TRUNCATION_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -Wformat-truncation HAVE_WFORMAT_TRUNCATION_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${HAVE_WFORMAT_TRUNCATION_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wformat-truncation>
    $<$<AND:$<BOOL:${HAVE_WFORMAT_TRUNCATION_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-Wformat-truncation>
)

php_check_compiler_flag(C -Wstrict-prototypes HAVE_WSTRICT_PROTOTYPES_C)
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${HAVE_WSTRICT_PROTOTYPES_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-Wstrict-prototypes>
)

php_check_compiler_flag(C -fno-common HAVE_FNO_COMMON_C)
if(CXX IN_LIST enabledLanguages)
  php_check_compiler_flag(CXX -fno-common HAVE_FNO_COMMON_CXX)
endif()
target_compile_options(
  php_config
  BEFORE
  INTERFACE
    $<$<AND:$<BOOL:${HAVE_FNO_COMMON_C}>,$<COMPILE_LANGUAGE:ASM,C>>:-fno-common>
    $<$<AND:$<BOOL:${HAVE_FNO_COMMON_CXX}>,$<COMPILE_LANGUAGE:CXX>>:-fno-common>
)

# Explicitly disable floating-point expression contraction, even if already done
# by CMAKE_C_STANDARD. See https://github.com/php/php-src/issues/14140
php_check_compiler_flag(C -ffp-contract=off HAVE_FFP_CONTRACT_OFF_C)
if(HAVE_FFP_CONTRACT_OFF_C)
  target_compile_options(
    php_config
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-ffp-contract=off>
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

  cmake_push_check_state(RESET)
    set(
      CMAKE_REQUIRED_LINK_OPTIONS
      -fsanitize=memory
      -fsanitize-memory-track-origins
    )

    php_check_compiler_flag(
      C
      "-fsanitize=memory;-fsanitize-memory-track-origins"
      HAVE_MEMORY_SANITIZER_C
    )

    if(CXX IN_LIST enabledLanguages)
      php_check_compiler_flag(
        CXX
        "-fsanitize=memory;-fsanitize-memory-track-origins"
        HAVE_MEMORY_SANITIZER_CXX
      )
    endif()
  cmake_pop_check_state()

  if(HAVE_MEMORY_SANITIZER_C OR HAVE_MEMORY_SANITIZER_CXX)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=memory;-fsanitize-memory-track-origins>
    )

    target_link_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=memory;-fsanitize-memory-track-origins>
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

    php_check_compiler_flag(C -fsanitize=address HAVE_ADDRESS_SANITIZER_C)
    if(CXX IN_LIST enabledLanguages)
      php_check_compiler_flag(CXX -fsanitize=address HAVE_ADDRESS_SANITIZER_CXX)
    endif()
  cmake_pop_check_state()

  if(HAVE_ADDRESS_SANITIZER_C OR HAVE_ADDRESS_SANITIZER_CXX)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=address>
    )

    target_link_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=address>
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
      HAVE_UNDEFINED_SANITIZER_C
    )
    if(CXX IN_LIST enabledLanguages)
      php_check_compiler_flag(
        CXX
        -fsanitize=undefined
        HAVE_UNDEFINED_SANITIZER_CXX
      )
    endif()
  cmake_pop_check_state()

  if(HAVE_UNDEFINED_SANITIZER_C OR HAVE_UNDEFINED_SANITIZER_CXX)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=undefined;-fno-sanitize-recover=undefined>
    )

    target_link_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=undefined;-fno-sanitize-recover=undefined>
    )

    # Disable object-size sanitizer, because it is incompatible with the
    # zend_function union, and this can't be easily fixed.
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LINK_OPTIONS "-fno-sanitize=object-size")

      php_check_compiler_flag(
        C
        -fno-sanitize=object-size
        HAVE_OBJECT_SIZE_SANITIZER_C
      )
      if(CXX IN_LIST enabledLanguages)
        php_check_compiler_flag(
          CXX
          -fno-sanitize=object-size
          HAVE_OBJECT_SIZE_SANITIZER_CXX
        )
      endif()
    cmake_pop_check_state()

    if(HAVE_OBJECT_SIZE_SANITIZER_C OR HAVE_OBJECT_SIZE_SANITIZER_CXX)
      target_compile_options(
        php_config
        INTERFACE
          $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fno-sanitize=object-size>
      )

      target_link_options(
        php_config
        INTERFACE
          $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fno-sanitize=object-size>
      )
    endif()

    # Clang 17 adds stricter function pointer compatibility checks where pointer
    # args cannot be cast to void*. In that case, set -fno-sanitize=function.
    if(
      NOT DEFINED PHP_HAVE_UBSAN_EXITCODE
      AND CMAKE_CROSSCOMPILING
      AND NOT CMAKE_CROSSCOMPILING_EMULATOR
      AND CMAKE_C_COMPILER_ID MATCHES "AppleClang|Clang"
      AND CMAKE_C_COMPILER_VERSION VERSION_GREATER_EQUAL 17
    )
      # When cross-compiling without emulator and using Clang 17 and greater,
      # assume that -fno-sanitize=function needs to be added.
      set(PHP_HAVE_UBSAN_EXITCODE 1)
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
      ]] PHP_HAVE_UBSAN)
    cmake_pop_check_state()

    if(NOT PHP_HAVE_UBSAN)
      php_check_compiler_flag(
        C
        -fno-sanitize=function
        HAVE_FNO_SANITIZE_FUNCTION_C
      )
      if(CXX IN_LIST enabledLanguages)
        php_check_compiler_flag(
          CXX
          -fno-sanitize=function
          HAVE_FNO_SANITIZE_FUNCTION_CXX
        )
      endif()

      if(HAVE_FNO_SANITIZE_FUNCTION_C)
        target_compile_options(
          php_config
          INTERFACE
            $<$<COMPILE_LANGUAGE:ASM,C>:-fno-sanitize=function>
        )
      endif()

      if(HAVE_FNO_SANITIZE_FUNCTION_CXX)
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
    HAVE_FNO_OMIT_FRAME_POINTER_C
  )
  if(CXX IN_LIST enabledLanguages)
    php_check_compiler_flag(
      CXX
      -fno-omit-frame-pointer
      HAVE_FNO_OMIT_FRAME_POINTER_CXX
    )
  endif()

  if(HAVE_FNO_OMIT_FRAME_POINTER_C)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C>:-fno-omit-frame-pointer>
    )
  endif()

  if(HAVE_FNO_OMIT_FRAME_POINTER_CXX)
    target_compile_options(
      php_config
      INTERFACE
        $<$<COMPILE_LANGUAGE:CXX>:-fno-omit-frame-pointer>
    )
  endif()
endif()

################################################################################
# Check linker flags.
################################################################################

# Align segments on huge page boundary.
include(PHP/CheckSegmentsAlignment)
