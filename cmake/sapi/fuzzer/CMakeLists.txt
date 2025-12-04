#[=============================================================================[
# The fuzzer SAPI

Configure the `fuzzer` PHP SAPI.

> [!NOTE]
> This SAPI is not available when the target system is Windows.

## PHP_SAPI_FUZZER

* Default: `OFF`
* Values: `ON|OFF`

Enable the fuzzer SAPI module - PHP as Clang fuzzing test module (for
developers). For relevant flags on newer Clang versions see
https://llvm.org/docs/LibFuzzer.html#fuzzer-usage

## LIB_FUZZING_ENGINE

* Default: empty

OSS-Fuzz: C++ compiler argument to link fuzz target against the prebuilt engine
library (e.g. libFuzzer). Can be also environment variable. See
https://google.github.io/oss-fuzz
#]=============================================================================]

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(
  PHP_SAPI_FUZZER
  "Enable the fuzzer SAPI module - Clang fuzzing test module (for developers)"
)

add_feature_info(
  "sapi/fuzzer"
  PHP_SAPI_FUZZER
  "Clang fuzzing module"
)

if(PHP_SAPI_FUZZER)
  set(
    CACHE{LIB_FUZZING_ENGINE}
    TYPE STRING
    HELP
      "OSS-Fuzz: Compiler argument to link fuzz target against the prebuilt "
      "engine library (e.g. libFuzzer)"
    VALUE ""
  )
  mark_as_advanced(LIB_FUZZING_ENGINE)
endif()

if(NOT PHP_SAPI_FUZZER)
  return()
endif()

if(PHP_THREAD_SAFETY)
  message(
    FATAL_ERROR
    "Thread safety (PHP_THREAD_SAFETY) is not supported when building fuzzing "
    "SAPI module (PHP_SAPI_FUZZER). Please build fuzzer without ZTS by setting "
    "PHP_THREAD_SAFETY to default 'OFF'."
  )
endif()

add_executable(php_sapi_fuzzer)
add_executable(PHP::sapi::fuzzer ALIAS php_sapi_fuzzer)

if(LIB_FUZZING_ENGINE OR DEFINED ENV{LIB_FUZZING_ENGINE})
  if(LIB_FUZZING_ENGINE)
    set(lib_fuzzing_engine "${LIB_FUZZING_ENGINE}")
  else()
    set(lib_fuzzing_engine "$ENV{LIB_FUZZING_ENGINE}")
  endif()
  message(STATUS "LIB_FUZZING_ENGINE=${lib_fuzzing_engine}")
  target_link_options(
    php_sapi_fuzzer
    INTERFACE
      "$<$<LINK_LANGUAGE:C,CXX>:${lib_fuzzing_engine}>"
  )
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LINK_OPTIONS -fsanitize=fuzzer-no-link)

    php_check_compiler_flag(
      C
      -fsanitize=fuzzer-no-link
      PHP_SAPI_FUZZER_HAS_FSANITIZE_FLAG_C
    )
    if(NOT PHP_SAPI_FUZZER_HAS_FSANITIZE_FLAG_C)
      message(
        FATAL_ERROR
        "The fuzzer SAPI cannot be enabled. C compiler ${CMAKE_C_COMPILER_ID} "
        "doesn't support the -fsanitize=fuzzer-no-link option."
      )
    endif()

    get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
    if(CXX IN_LIST languages)
      php_check_compiler_flag(
        CXX
        -fsanitize=fuzzer-no-link
        PHP_SAPI_FUZZER_HAS_FSANITIZE_FLAG_CXX
      )
      if(NOT PHP_SAPI_FUZZER_HAS_FSANITIZE_FLAG_CXX)
        message(
          FATAL_ERROR
          "The fuzzer SAPI cannot be enabled. C++ compiler "
          "${CMAKE_CXX_COMPILER_ID} doesn't support the "
          "-fsanitize=fuzzer-no-link option."
        )
      endif()
    endif()
  cmake_pop_check_state()

  target_compile_options(
    php_config
    INTERFACE $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=fuzzer-no-link>
  )

  target_link_options(
    php_sapi_fuzzer
    PRIVATE $<$<LINK_LANGUAGE:C,CXX>:-fsanitize=fuzzer>
  )
endif()

target_sources(php_sapi_fuzzer PRIVATE fuzzer-sapi.c)

set_target_properties(
  php_sapi_fuzzer
  PROPERTIES
    EXPORT_NAME Sapi::Fuzzer
    OUTPUT_NAME ${PHP_PROGRAM_PREFIX}fuzzer${PHP_PROGRAM_SUFFIX}
)

target_link_libraries(
  php_sapi_fuzzer
  PRIVATE
    $<BUILD_INTERFACE:PHP::sapi>
)

install(
  TARGETS php_sapi_fuzzer
  RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
    COMPONENT php-sapi-fuzzer
)
