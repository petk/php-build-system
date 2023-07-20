option(phpdbg "Whether to use the PHP PHPDBG SAPI module" ON)

bison_target(PhpDbgParser phpdbg_parser.y ${CMAKE_CURRENT_BINARY_DIR}/phpdbg_parser.c
  COMPILE_FLAGS "-v -d"
  DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/phpdbg_parser.h
)
