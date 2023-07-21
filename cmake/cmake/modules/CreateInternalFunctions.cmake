#[=============================================================================[
Creates main/internal_functions.c and main/internal_functions_cli.c files.
]=============================================================================]#

set(EXT_INCLUDE_CODE "")
set(EXT_MODULE_PTRS "")

# Add artefacts of static enabled PHP extensions to symbol definitions.
foreach(item IN LISTS PHP_EXTENSIONS)
  if(${${item}} EQUAL ON)
    set(EXT_INCLUDE_CODE "${EXT_INCLUDE_CODE}\n#include \"ext/${item}/php_${item}.h\"")

    set(EXT_MODULE_PTRS "${EXT_MODULE_PTRS}\n\tphpext_${item}_ptr,")
  endif()
  continue()

  #string(TOLOWER ${${item}} ${item}_lower)
endforeach()

message(STATUS "Creating main/internal_functions.c")
configure_file(main/internal_functions.c.in main/internal_functions.c)

message(STATUS "Creating main/internal_functions_cli.c")
configure_file(main/internal_functions.c.in main/internal_functions_cli.c)
