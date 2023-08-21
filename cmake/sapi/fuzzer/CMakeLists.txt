option(fuzzer "Whether to use the PHP Fuzzer SAPI module" OFF)

if(NOT fuzzer)
  return()
endif()
