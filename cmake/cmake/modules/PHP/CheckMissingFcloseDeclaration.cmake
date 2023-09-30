#[=============================================================================[
Check if fclose declaration is missing.

Some systems have broken header files like SunOS has.

The module sets the following variables:

MISSING_FCLOSE_DECL
  Set to true if fclose declaration is missing.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for fclose declaration")

check_c_source_compiles("
  #include <stdio.h>

  int main(void) {
    int (*func)() = fclose;

    return 0;
  }
" _fclose_declaration_works)

if(NOT _fclose_declaration_works)
  set(MISSING_FCLOSE_DECL ${_missing} CACHE INTERNAL "Set to 1 if fclose declaration is missing")
endif()
