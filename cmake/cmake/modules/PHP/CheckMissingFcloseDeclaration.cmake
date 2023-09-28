#[=============================================================================[
Checks if fclose declaration is missing.

The module sets the following variables:

MISSING_FCLOSE_DECL
  Set to true if fclose declaration is missing, false otherwise.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for fclose declaration")

check_c_source_compiles("
  #include <stdio.h>

  int main(void) {
    int (*func)() = fclose;

    return 0;
  }
" _compilation_result)

if(_compilation_result)
  set(_missing 0)
else()
  set(_missing 1)
endif()

set(MISSING_FCLOSE_DECL ${_missing} CACHE INTERNAL "fclose declaration is ok")

unset(_compilation_result)
unset(_missing)
