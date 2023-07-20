#[=============================================================================[
Generates internal_functions.c and internal_functions_cli.c files.
]=============================================================================]#

set(EXT_INCLUDE_CODE "")
set(EXT_MODULE_PTRS "")

foreach(item IN LISTS PHP_EXTENSIONS)
  set(EXT_INCLUDE_CODE "${EXT_INCLUDE_CODE}\n#include \"ext/${item}/php_${item}.h\"")

  set(EXT_MODULE_PTRS "${EXT_MODULE_PTRS}\n\tphpext_${item}_ptr,")
endforeach()

message(STATUS "Creating main/internal_functions.c")
configure_file(main/internal_functions.c.in main/internal_functions.c)

message(STATUS "Creating main/internal_functions_cli.c")
configure_file(main/internal_functions.c.in main/internal_functions_cli.c)
