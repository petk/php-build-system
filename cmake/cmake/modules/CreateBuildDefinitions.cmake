#[=============================================================================[
Create build definitions header file main/build-defs.h.

Function: create_build_definitions()
]=============================================================================]#

function(create_build_definitions)
  message(STATUS "Creating main/build-defs.h")

  set(HAVE_BUILD_DEFS_H 1 CACHE STRING "Define to 1 if you have the build-defs.h header file.")

  set(INCLUDE_PATH ".:" CACHE STRING "The include_path directive.")

  configure_file(main/build-defs.h.in main/build-defs.h @ONLY)
endfunction()
