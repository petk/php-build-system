option(SAPI_FUZZER "Whether to use the PHP Fuzzer SAPI module" OFF)

if(NOT SAPI_FUZZER)
  return()
endif()

#add_executable(php_fuzzer)
#set_target_properties(php_fuzzer PROPERTIES OUTPUT_NAME fuzzer)
#target_link_libraries(php_fuzzer PRIVATE PHP::main)
#install(TARGETS php_fuzzer DESTINATION ${CMAKE_INSTALL_BINDIR})
