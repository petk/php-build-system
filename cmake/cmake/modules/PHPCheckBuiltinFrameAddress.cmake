#[=============================================================================[
Checks whether compiler supports __builtin_frame_address.

Module sets the following variables:

PHP_HAVE_BUILTIN_FRAME_ADDRESS
  Set to true if compiler supports __builtin_frame_address, false otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_frame_address")

check_c_source_compiles("
  int main (void) {
    return __builtin_frame_address(0) != (void*)0;
  }
" PHP_HAVE_BUILTIN_FRAME_ADDRESS)
