#[=============================================================================[
Check and configure compilation options.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckCompilerFlag)
include(CheckLinkerFlag)
include(CheckSourceRuns)
include(CMakePushCheckState)

# Check for broken GCC optimize-strlen.
include(PHP/CheckBrokenGccStrlenOpt)
if(HAVE_BROKEN_OPTIMIZE_STRLEN)
  check_compiler_flag(C -fno-optimize-strlen HAVE_FNO_OPTIMIZE_STRLEN_C)
  if(HAVE_FNO_OPTIMIZE_STRLEN_C)
    target_compile_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C>:-fno-optimize-strlen>
    )
  endif()
endif()

# Mark symbols hidden by default if the compiler (for example, GCC >= 4)
# supports it. This can help reduce the binary size and startup time.
check_compiler_flag(C -fvisibility=hidden HAVE_FVISIBILITY_HIDDEN_C)
if(HAVE_FVISIBILITY_HIDDEN_C)
  target_compile_options(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-fvisibility=hidden>
  )
endif()

target_compile_options(
  php_configuration
  BEFORE
  INTERFACE
    $<$<COMPILE_LANG_AND_ID:ASM,GNU>:-Wall;-Wextra;-Wno-unused-parameter;-Wno-sign-compare>
    $<$<COMPILE_LANG_AND_ID:C,GNU>:-Wall;-Wextra;-Wno-unused-parameter;-Wno-sign-compare>
    $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Wall;-Wextra;-Wno-unused-parameter;-Wno-sign-compare>
)

# Check if compiler supports -Wno-clobbered (only GCC).
check_compiler_flag(C -Wno-clobbered HAVE_WNO_CLOBBERED_C)
if(HAVE_WNO_CLOBBERED_C)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-Wno-clobbered>
  )
endif()
check_compiler_flag(CXX -Wno-clobbered HAVE_WNO_CLOBBERED_CXX)
if(HAVE_WNO_CLOBBERED_CXX)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:-Wno-clobbered>
  )
endif()

# Check for support for implicit fallthrough level 1, also add after previous
# CFLAGS as level 3 is enabled in -Wextra.
check_compiler_flag(C -Wimplicit-fallthrough=1 HAVE_WIMPLICIT_FALLTHROUGH_1_C)
if(HAVE_WIMPLICIT_FALLTHROUGH_1_C)
  target_compile_options(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-Wimplicit-fallthrough=1>
  )
endif()
check_compiler_flag(
  CXX
  -Wimplicit-fallthrough=1
  HAVE_WIMPLICIT_FALLTHROUGH_1_CXX
)
if(HAVE_WIMPLICIT_FALLTHROUGH_1_CXX)
  target_compile_options(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:-Wimplicit-fallthrough=1>
  )
endif()

check_compiler_flag(C -Wduplicated-cond HAVE_WDUPLICATED_COND_C)
if(HAVE_WDUPLICATED_COND_C)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-Wduplicated-cond>
  )
endif()
check_compiler_flag(CXX -Wduplicated-cond HAVE_WDUPLICATED_COND_CXX)
if(HAVE_WDUPLICATED_COND_CXX)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:-Wduplicated-cond>
  )
endif()

check_compiler_flag(C -Wlogical-op HAVE_WLOGICAL_OP_C)
if(HAVE_WLOGICAL_OP_C)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-Wlogical-op>
  )
endif()
check_compiler_flag(CXX -Wlogical-op HAVE_WLOGICAL_OP_CXX)
if(HAVE_WLOGICAL_OP_CXX)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:-Wlogical-op>
  )
endif()

check_compiler_flag(C -Wformat-truncation HAVE_WFORMAT_TRUNCATION_C)
if(HAVE_WFORMAT_TRUNCATION_C)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-Wformat-truncation>
  )
endif()
check_compiler_flag(CXX -Wformat-truncation HAVE_WFORMAT_TRUNCATION_CXX)
if(HAVE_WFORMAT_TRUNCATION_CXX)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:-Wformat-truncation>
  )
endif()

check_compiler_flag(C -Wstrict-prototypes HAVE_WSTRICT_PROTOTYPES_C)
if(HAVE_WSTRICT_PROTOTYPES_C)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-Wstrict-prototypes>
  )
endif()

check_compiler_flag(C -fno-common HAVE_FNO_COMMON_C)
if(HAVE_FNO_COMMON_C)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-fno-common>
  )
endif()
check_compiler_flag(CXX -fno-common HAVE_FNO_COMMON_CXX)
if(HAVE_FNO_COMMON_C_XX)
  target_compile_options(
    php_configuration
    BEFORE
    INTERFACE
      $<$<COMPILE_LANGUAGE:CXX>:-fno-common>
  )
endif()

# Explicitly disable floating-point expression contraction, even if already done
# by CMAKE_C_STANDARD. See https://github.com/php/php-src/issues/14140
check_compiler_flag(C -ffp-contract=off HAVE_FFP_CONTRACT_OFF_C)
if(HAVE_FFP_CONTRACT_OFF_C)
  target_compile_options(
    php_configuration
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
    "MemorySanitizer and AddressSanitizer are mutually exclusive"
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

    check_compiler_flag(
      C
      "-fsanitize=memory;-fsanitize-memory-track-origins"
      HAVE_MEMORY_SANITIZER_C
    )

    check_compiler_flag(
      CXX
      "-fsanitize=memory;-fsanitize-memory-track-origins"
      HAVE_MEMORY_SANITIZER_CXX
    )
  cmake_pop_check_state()

  if(HAVE_MEMORY_SANITIZER_C AND HAVE_MEMORY_SANITIZER_CXX)
    target_compile_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=memory;-fsanitize-memory-track-origins>
    )

    target_link_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=memory;-fsanitize-memory-track-origins>
    )

    message(CHECK_PASS "Success")
  else()
    message(CHECK_FAIL "Failed")
    message(FATAL_ERROR "MemorySanitizer is not available")
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

    check_compiler_flag(C "-fsanitize=address" HAVE_ADDRESS_SANITIZER_C)
    check_compiler_flag(CXX "-fsanitize=address" HAVE_ADDRESS_SANITIZER_CXX)
  cmake_pop_check_state()

  if(HAVE_ADDRESS_SANITIZER_C AND HAVE_ADDRESS_SANITIZER_CXX)
    target_compile_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=address>
    )

    target_link_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=address>
    )

    target_compile_definitions(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:ZEND_TRACK_ARENA_ALLOC>
    )

    message(CHECK_PASS "Success")
  else()
    message(CHECK_FAIL "Failed")
    message(FATAL_ERROR "AddressSanitizer is not available")
  endif()
endif()

# Enable the -fsanitize=undefined compiler option.
if(PHP_UNDEFINED_SANITIZER)
  message(CHECK_START "Checking undefined sanitizer compiler options")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LINK_OPTIONS "-fsanitize=undefined")

    check_compiler_flag(C "-fsanitize=undefined" HAVE_UNDEFINED_SANITIZER_C)
    check_compiler_flag(CXX "-fsanitize=undefined" HAVE_UNDEFINED_SANITIZER_CXX)
  cmake_pop_check_state()

  if(HAVE_UNDEFINED_SANITIZER_C AND HAVE_UNDEFINED_SANITIZER_CXX)
    target_compile_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=undefined;-fno-sanitize-recover=undefined>
    )

    target_link_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=undefined;-fno-sanitize-recover=undefined>
    )

    # Disable object-size sanitizer, because it is incompatible with the
    # zend_function union, and this can't be easily fixed.
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LINK_OPTIONS "-fno-sanitize=object-size")

      check_compiler_flag(C "-fno-sanitize=object-size" HAVE_OBJECT_SIZE_SANITIZER_C)
      check_compiler_flag(CXX "-fno-sanitize=object-size" HAVE_OBJECT_SIZE_SANITIZER_CXX)
    cmake_pop_check_state()

    if(HAVE_OBJECT_SIZE_SANITIZER_C AND HAVE_OBJECT_SIZE_SANITIZER_CXX)
      target_compile_options(
        php_configuration
        INTERFACE
          $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fno-sanitize=object-size>
      )

      target_link_options(
        php_configuration
        INTERFACE
          $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fno-sanitize=object-size>
      )
    endif()

    # Clang 17 adds stricter function pointer compatibility checks where pointer
    # args cannot be cast to void*. In that case, set -fno-sanitize=function.
    if(NOT CMAKE_CROSSCOMPILING)
      cmake_push_check_state(RESET)
        set(CMAKE_REQUIRED_FLAGS -fno-sanitize-recover=undefined)
        check_source_runs(C [[
          void foo(char *string) {}
          int main(void) {
            void (*f)(void *) = (void (*)(void *))foo;
            f("foo");
          }
        ]] _php_ubsan_works)
      cmake_pop_check_state()

      if(NOT _php_ubsan_works)
        check_compiler_flag(C -fno-sanitize=function HAVE_FNO_SANITIZE_FUNCTION_C)
        check_compiler_flag(CXX -fno-sanitize=function HAVE_FNO_SANITIZE_FUNCTION_CXX)

        if(HAVE_FNO_SANITIZE_FUNCTION_C)
          target_compile_options(
            php_configuration
            INTERFACE
              $<$<COMPILE_LANGUAGE:ASM,C>:-fno-sanitize=function>
          )
        endif()

        if(HAVE_FNO_SANITIZE_FUNCTION_CXX)
          target_compile_options(
            php_configuration
            INTERFACE
              $<$<COMPILE_LANGUAGE:CXX>:-fno-sanitize=function>
          )
        endif()
      endif()
    endif()

    message(CHECK_PASS "Success")
  else()
    message(CHECK_FAIL "Failed")
    message(FATAL_ERROR "UndefinedBehaviorSanitizer is not available")
  endif()
endif()

if(PHP_MEMORY_SANITIZER OR PHP_ADDRESS_SANITIZER OR PHP_UNDEFINED_SANITIZER)
  check_compiler_flag(C -fno-omit-frame-pointer HAVE_FNO_OMIT_FRAME_POINTER_C)
  check_compiler_flag(CXX -fno-omit-frame-pointer HAVE_FNO_OMIT_FRAME_POINTER_CXX)

  if(HAVE_FNO_OMIT_FRAME_POINTER_C)
    target_compile_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:ASM,C>:-fno-omit-frame-pointer>
    )
  endif()

  if(HAVE_FNO_OMIT_FRAME_POINTER_CXX)
    target_compile_options(
      php_configuration
      INTERFACE
        $<$<COMPILE_LANGUAGE:CXX>:-fno-omit-frame-pointer>
    )
  endif()
endif()

################################################################################
# Check linker flags.
################################################################################

# Align segments on huge page boundary.
message(
  CHECK_START
  "Checking linker support for aligning segments on huge page boundary"
)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux"
  AND CMAKE_SYSTEM_PROCESSOR MATCHES "^(i[3456]86.*|x86_64)$"
)
  check_linker_flag(
    C
    "LINKER:-z,common-page-size=2097152;LINKER:-z,max-page-size=2097152"
    HAVE_ALIGNMENT_FLAGS_C
  )

  if(HAVE_ALIGNMENT_FLAGS_C)
    target_link_options(
      php_configuration
      INTERFACE
        $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,$<COMPILE_LANGUAGE:ASM,C>>:LINKER:-z,common-page-size=2097152;LINKER:-z,max-page-size=2097152>
    )
  else()
    check_linker_flag(
      C
      "LINKER:-z,max-page-size=2097152"
      HAVE_ZMAX_PAGE_SIZE_C
    )

    if(HAVE_ZMAX_PAGE_SIZE_C)
      target_link_options(
        php_configuration
        INTERFACE
          $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,$<COMPILE_LANGUAGE:ASM,C>>:LINKER:-z,max-page-size=2097152>
      )
    endif()
  endif()

  check_linker_flag(
    CXX
    "LINKER:-z,common-page-size=2097152;LINKER:-z,max-page-size=2097152"
    HAVE_ALIGNMENT_FLAGS_CXX
  )

  if(HAVE_ALIGNMENT_FLAGS_CXX)
    target_link_options(
      php_configuration
      INTERFACE
        $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,$<COMPILE_LANGUAGE:CXX>>:LINKER:-z,common-page-size=2097152;LINKER:-z,max-page-size=2097152>
    )
  else()
    check_linker_flag(
      CXX
      "LINKER:-z,max-page-size=2097152"
      HAVE_ZMAX_PAGE_SIZE_CXX
    )

    if(HAVE_ZMAX_PAGE_SIZE_CXX)
      target_link_options(
        php_configuration
        INTERFACE
          $<$<AND:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,$<COMPILE_LANGUAGE:CXX>>:LINKER:-z,max-page-size=2097152>
      )
    endif()
  endif()

  if(HAVE_ALIGNMENT_FLAGS_C AND HAVE_ALIGNMENT_FLAGS_CXX)
    message(CHECK_PASS "yes")
  elseif(HAVE_ZMAX_PAGE_SIZE_C AND HAVE_ZMAX_PAGE_SIZE_CXX)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
else()
  message(CHECK_FAIL "no")
endif()

# Check if -Wno-typedef-redefinition compile option is supported by the
# compiler. PHP is written with C99 standard in mind, but a possibility that
# typedef redefinitions might happened in the source code. Since CMake build
# system also uses the CMAKE_C_STANDARD_REQUIRED (which adds the -std=...
# compilation option), GCC recent versions usually ignore this and don't emit
# the warnings, however Clang emits warnings that redeclaring typedef is a C11
# feature. Clang has this option to turn off these warnings. As of C11, the
# typedef redefinitions are a valid programming way, and this can be removed
# when using a required CMAKE_C_STANDARD 11.
check_compiler_flag(C -Wno-typedef-redefinition _HAVE_WNO_TYPEDEF_REDEFINITION)
if(_HAVE_WNO_TYPEDEF_REDEFINITION)
  target_compile_options(
    php_configuration
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C>:-Wno-typedef-redefinition>
  )
endif()
