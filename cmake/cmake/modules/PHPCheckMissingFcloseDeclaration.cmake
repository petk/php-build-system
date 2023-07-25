#[=============================================================================[
Checks if fclose declaration is missing.

The module defines the following variables:

``MISSING_FCLOSE_DECL``
  Defined to 1 if fclose declaration is missing, otherwise 0.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking for fclose declaration")

check_c_source_compiles("
  #include <stdio.h>

  int main (void)
  {
    int (*func)() = fclose;
    return 0;
  }
" COMPILATION_RESULT)

if(COMPILATION_RESULT)
  message(STATUS "ok")
  set(MISSING_FCLOSE_DECL 0 CACHE STRING "fclose declaration is ok")
else()
  message(STATUS "missing")
  set(MISSING_FCLOSE_DECL 1 CACHE STRING "fclose declaration is missing")
endif()
