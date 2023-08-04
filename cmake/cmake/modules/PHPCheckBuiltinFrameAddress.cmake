#[=============================================================================[
Checks whether compiler supports __builtin_frame_address.

Module sets the following variables:

``PHP_HAVE_BUILTIN_FRAME_ADDRESS``
  Set to 1 if compiler supports __builtin_frame_address, 0 otherwise.
]=============================================================================]#
include(CheckCSourceCompiles)

message(STATUS "Checking for __builtin_frame_address")

check_c_source_compiles("
  int main (void) {
    return __builtin_frame_address(0) != (void*)0;
  }
" have_builtin_frame_address)

if(have_builtin_frame_address)
  set(have_builtin_frame_address 1)
else()
  set(have_builtin_frame_address 0)
endif()

set(PHP_HAVE_BUILTIN_FRAME_ADDRESS ${have_builtin_frame_address} CACHE INTERNAL "Whether the compiler supports __builtin_frame_address")

unset(have_builtin_frame_address)
