set(PTHREADS 1)

message(STATUS "Checking for POSIX threads")

add_library(TSRM TSRM.c)

target_include_directories(
  TSRM
  INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(TSRM PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
