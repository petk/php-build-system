include(CMakeDependentOption)

option(SAPI_PHPDBG "Whether to use the PHP PHPDBG SAPI module" ON)

# TODO: Check if this can be simplified and removed in favor of the PHP_DEBUG option.
cmake_dependent_option(SAPI_PHPDBG_DEBUG "" OFF "SAPI_PHPDBG" OFF)
# TODO: Check if this can be simplified and removed in favor of the readline option.
cmake_dependent_option(SAPI_PHPDBG_READLINE "" OFF "SAPI_PHPDBG" OFF)

if(NOT SAPI_PHPDBG)
  return()
endif()

bison_target(PhpDbgParser phpdbg_parser.y ${CMAKE_CURRENT_BINARY_DIR}/phpdbg_parser.c
  COMPILE_FLAGS "-v -d"
  DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/phpdbg_parser.h
)

re2c_target(
  NAME phpdbgLexer
  INPUT "${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.l"
  OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/phpdbg_lexer.c"
  OPTIONS "--no-generation-date -cbdF"
)

add_executable(phpdbg
  phpdbg.c
  phpdbg_parser.c
  phpdbg_lexer.c
  phpdbg_prompt.c
  phpdbg_help.c
  phpdbg_break.c
  phpdbg_print.c
  phpdbg_bp.c
  phpdbg_list.c
  phpdbg_utils.c
  phpdbg_info.c
  phpdbg_cmd.c
  phpdbg_set.c
  phpdbg_frame.c
  phpdbg_watch.c
  phpdbg_btree.c
  phpdbg_sigsafe.c
  phpdbg_io.c
  phpdbg_out.c
)

target_compile_definitions(
  phpdbg
  PRIVATE
    _GNU_SOURCE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

target_link_libraries(phpdbg PUBLIC main)
target_link_libraries(phpdbg PUBLIC TSRM)
target_link_libraries(phpdbg PUBLIC Zend)

foreach(item IN LISTS PHP_EXTENSIONS)
  message(STATUS "Linking ${item}")
  target_link_libraries(phpdbg PUBLIC ext_${item})
endforeach()

if(EXTRA_LIBS)
  target_link_libraries(phpdbg PUBLIC ${EXTRA_LIBS})
endif()

if(EXTRA_DEFINITIONS)
  target_compile_definitions(phpdbg PUBLIC ${EXTRA_DEFINITIONS})
endif()
