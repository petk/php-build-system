option(SAPI_FUZZER "Whether to use the PHP Fuzzer SAPI module" OFF)

if(NOT SAPI_FUZZER)
  return()
endif()
