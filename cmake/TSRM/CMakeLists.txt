message(STATUS "Checking for POSIX threads")

add_library(TSRM STATIC TSRM.c)

target_compile_definitions(TSRM PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

file(GLOB_RECURSE _tsrm_headers "${PROJECT_SOURCE_DIR}/TSRM/*.h")
install(FILES ${_tsrm_headers} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/TSRM)
