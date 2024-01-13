#[=============================================================================[
Setup Ccache for faster compilation times.
https://ccache.dev

Cache variables:

  CCACHE_EXECUTABLE
    Path to the ccache executable.
]=============================================================================]#

find_program(CCACHE_EXECUTABLE ccache)
mark_as_advanced(CCACHE_EXECUTABLE)

if(NOT CCACHE_EXECUTABLE OR CCACHE_DISABLE OR "$ENV{CCACHE_DISABLE}")
  return()
endif()

message(STATUS "Using ccache (${CCACHE_EXECUTABLE})")

set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_EXECUTABLE})
set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_EXECUTABLE})
