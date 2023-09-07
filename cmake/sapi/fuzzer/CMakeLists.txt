option(SAPI_FUZZER "Whether to use the PHP Fuzzer SAPI module" OFF)

if(NOT SAPI_FUZZER)
  return()
endif()

#install(TARGETS fuzzer DESTINATION ${CMAKE_INSTALL_BINDIR})
