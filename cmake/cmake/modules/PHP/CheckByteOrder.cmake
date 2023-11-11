#[=============================================================================[
Check whether system byte ordering is big-endian.

Cache variables:

  WORDS_BIGENDIAN
    Whether byte ordering is big-endian.
]=============================================================================]#

include(CheckCSourceRuns)

if(CMAKE_C_BYTE_ORDER STREQUAL "BIG_ENDIAN")
  message(STATUS "Byte ordering is big-endian")
  set(WORDS_BIGENDIAN 1 CACHE INTERNAL "Define if processor uses big-endian words")
elseif(CMAKE_C_BYTE_ORDER STREQUAL "LITTLE_ENDIAN")
  message(STATUS "Byte ordering is little-endian")
else()
  if(NOT CMAKE_CROSSCOMPILING)
    check_c_source_runs("
      int main(void) {
        short one = 1;
        char *cp = (char *)&one;

        if (*cp == 0) {
          return(0);
        } else {
          return(1);
        }
      }
    " WORDS_BIGENDIAN)

    if(WORDS_BIGENDIAN)
      message(STATUS "Byte ordering is big-endian")
    endif()
  else()
    message(WARNING "Byte ordering is unknown")
  endif()
endif()
