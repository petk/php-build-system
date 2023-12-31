include(CheckCompilerFlag)

option(SAPI_FUZZER "Enable the Fuzzer SAPI module" OFF)

message(CHECK_START "Checking whether to build fuzzer SAPI")
if(SAPI_FUZZER)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()

if(NOT SAPI_FUZZER)
  return()
endif()

#add_executable(php_fuzzer)
#set_target_properties(php_fuzzer PROPERTIES OUTPUT_NAME fuzzer)
#target_link_libraries(php_fuzzer PRIVATE PHP::main)
#install(TARGETS php_fuzzer DESTINATION "${CMAKE_INSTALL_BINDIR}")

if(LIB_FUZZING_ENGINE)
  check_compiler_flag(C -fsanitize=fuzzer-no-link HAVE_FSANITIZE_FUZZER_NO_LINK_C)
  check_compiler_flag(CXX -fsanitize=fuzzer-no-link HAVE_FSANITIZE_FUZZER_NO_LINK_CXX)

  if(HAVE_FSANITIZE_FUZZER_NO_LINK_C AND HAVE_FSANITIZE_FUZZER_NO_LINK_CXX)
    target_compile_options(php_configuration
      INTERFACE $<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fsanitize=fuzzer-no-link>
    )
  endif()
endif()
