# SAPI is only for *nix systems.
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(
  SAPI_FUZZER
  "Enable the fuzzer SAPI module - PHP as Clang fuzzing test module (for\
  developers). For relevant flags on newer Clang versions see\
  https://llvm.org/docs/LibFuzzer.html#fuzzer-usage"
  OFF
)

add_feature_info(
  "sapi/fuzzer"
  SAPI_FUZZER
  "Clang fuzzing SAPI module"
)

if(SAPI_FUZZER)
  set(
    LIB_FUZZING_ENGINE
    ""
    CACHE STRING
    "OSS-Fuzz: C++ compiler argument to link fuzz target against the prebuilt\
    engine library (e.g. libFuzzer). Can be also environment variable. See\
    https://google.github.io/oss-fuzz"
  )
  mark_as_advanced(LIB_FUZZING_ENGINE)
endif()

message(CHECK_START "Checking whether to build fuzzer SAPI")
if(SAPI_FUZZER)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
  return()
endif()

if(PHP_THREAD_SAFETY)
  message(
    FATAL_ERROR
    "Thread safety (PHP_THREAD_SAFETY) is not supported when building fuzzing "
    "SAPI module (SAPI_FUZZER). Please build fuzzer without ZTS by setting "
    "PHP_THREAD_SAFETY to default 'OFF'."
  )
endif()

if(LIB_FUZZING_ENGINE OR "$ENV{LIB_FUZZING_ENGINE}")
  if(LIB_FUZZING_ENGINE)
    set(libFuzzingEngine "${LIB_FUZZING_ENGINE}")
  else()
    set(libFuzzingEngine "$ENV{LIB_FUZZING_ENGINE}")
  endif()
  message(STATUS "LIB_FUZZING_ENGINE=${libFuzzingEngine}")
  target_link_options(
    php_fuzzer
    INTERFACE
      "$<$<COMPILE_LANGUAGE:ASM,C,CXX>:${libFuzzingEngine}>"
  )
else()
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LINK_OPTIONS -fsanitize=fuzzer-no-link)

    php_check_compiler_flag(
      C
      -fsanitize=fuzzer-no-link
      HAVE_FSANITIZE_FUZZER_NO_LINK_C
    )

    php_check_compiler_flag(
      CXX
      -fsanitize=fuzzer-no-link
      HAVE_FSANITIZE_FUZZER_NO_LINK_CXX
    )
  cmake_pop_check_state()

  if(NOT HAVE_FSANITIZE_FUZZER_NO_LINK_C)
    message(
      FATAL_ERROR
      "The fuzzer SAPI cannot be enabled. C compiler ${CMAKE_C_COMPILER_ID} "
      "doesn't support the -fsanitize=fuzzer-no-link option."
    )
  endif()

  if(NOT HAVE_FSANITIZE_FUZZER_NO_LINK_CXX)
    message(
      FATAL_ERROR
      "The fuzzer SAPI cannot be enabled. C++ compiler "
      "${CMAKE_CXX_COMPILER_ID} doesn't support the -fsanitize=fuzzer-no-link "
      "option"
    )
  endif()

  target_compile_options(
    php_configuration
    INTERFACE $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=fuzzer-no-link>
  )

  target_link_options(
    php_fuzzer
    INTERFACE
      $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=fuzzer>
  )
endif()

#add_executable(php_fuzzer)
#set_target_properties(php_fuzzer PROPERTIES OUTPUT_NAME fuzzer)
#target_link_libraries(php_fuzzer PRIVATE PHP::main)
#install(TARGETS php_fuzzer DESTINATION ${CMAKE_INSTALL_BINDIR})
