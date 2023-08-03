#[=============================================================================[
Checks whether the system uses EBCDIC (not ASCII) as its native codeset.
]=============================================================================]#

include(CheckCSourceRuns)

message(STATUS "Check whether system uses EBCDIC")

if(CMAKE_CROSSCOMPILING)
  set(is_ebcdic OFF)
else()
  check_c_source_runs("
    int main(void) {
      return (unsigned char)'A' != (unsigned char)0xC1;
    }
  " is_ebcdic)
endif()

if(is_ebcdic)
  message(FATAL_ERROR "PHP does not support EBCDIC targets")
endif()

unset(is_ebcdic)
