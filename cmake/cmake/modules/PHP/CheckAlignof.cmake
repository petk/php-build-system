#[=============================================================================[
Check for __alignof__ support in the compiler.

Module sets the following variables:

HAVE_ALIGNOF
  Set to 1 if compiler supports __alignof__.
]=============================================================================]#

include(CheckCSourceCompiles)

message(CHECK_START "Checking whether the compiler supports __alignof__")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

check_c_source_compiles("
  int main(void) {
    int align = __alignof__(int);

    return 0;
  }
" HAVE_ALIGNOF)

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_ALIGNOF)
  message(CHECK_PASS "yes")
else()
  message(CHECK_FAIL "no")
endif()
