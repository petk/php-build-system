#[=============================================================================[
Configure project after the project() call.
#]=============================================================================]

include_guard(GLOBAL)

# Output linker information.
if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
  if(CMAKE_C_COMPILER_LINKER)
    message(STATUS "C linker: ${CMAKE_C_COMPILER_LINKER}")
  endif()
  if(CMAKE_CXX_COMPILER_LINKER)
    message(STATUS "CXX linker: ${CMAKE_CXX_COMPILER_LINKER}")
  endif()
endif()

# Check whether to enable interprocedural optimization.
include(PHP/InterproceduralOptimization)

# Set CMAKE_POSITION_INDEPENDENT_CODE.
include(PHP/PositionIndependentCode)
