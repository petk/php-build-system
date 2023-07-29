#[=============================================================================[
Checks for __alignof__ support in the compiler.

Module sets the following variables:

``HAVE_ALIGNOF``
  Set to 1 if compiler supports __alignof__.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking whether the compiler supports __alignof__")

check_c_source_compiles("
  int main (void) {
    int align = __alignof__(int);
    return 0;
  }
" have_alignof)

if(have_alignof)
  set(HAVE_ALIGNOF 1 CACHE STRING "whether the compiler supports __alignof__")
endif()
