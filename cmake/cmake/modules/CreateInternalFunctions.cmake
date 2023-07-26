#[=============================================================================[
Creates main/internal_functions.c and main/internal_functions_cli.c files.
]=============================================================================]#

set(EXT_INCLUDE_CODE "")
set(EXT_MODULE_PTRS "")

# Add artefacts of static enabled PHP extensions to symbol definitions.
foreach(extension IN LISTS PHP_EXTENSIONS)
  # Skip if extension is shared.
  if(extension IN_LIST PHP_EXTENSIONS_SHARED)
    continue()
  endif()

  file(GLOB_RECURSE extension_headers
    "${PROJECT_SOURCE_DIR}/ext/${extension}/*.h"
  )

  foreach(extension_header IN LISTS extension_headers)
    file(READ "${extension_header}" file_content)
    string(FIND "${file_content}" "phpext_" pattern_index)

    if (NOT pattern_index EQUAL -1)
      get_filename_component(file_name "${extension_header}" NAME)
      set(EXT_INCLUDE_CODE "${EXT_INCLUDE_CODE}\n#include \"ext/${extension}/${file_name}\"")
    endif()
  endforeach()

  set(EXT_MODULE_PTRS "${EXT_MODULE_PTRS}\n\tphpext_${extension}_ptr,")
endforeach()

message(STATUS "Creating main/internal_functions.c")
configure_file(main/internal_functions.c.in main/internal_functions.c)

message(STATUS "Creating main/internal_functions_cli.c")
configure_file(main/internal_functions.c.in main/internal_functions_cli.c)
