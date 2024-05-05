#[=============================================================================[
Enable interprocedural optimization (IPO), if supported.

Interprocedural optimization adds linker flag (-flto) if it is supported by the
compiler to run standard link-time optimizer.

It can be also controlled more granular by the user with the
CMAKE_INTERPROCEDURAL_OPTIMIZATION_<CONFIG> variables based on the build type.

https://cmake.org/cmake/help/latest/prop_tgt/INTERPROCEDURAL_OPTIMIZATION.html
]=============================================================================]#

include_guard(GLOBAL)

# Whether to enable interprocedural optimization on all the targets.
option(
  CMAKE_INTERPROCEDURAL_OPTIMIZATION
  "Enable interprocedural optimization (IPO) if compiler supports it"
  ON
)
mark_as_advanced(CMAKE_INTERPROCEDURAL_OPTIMIZATION)

if(NOT CMAKE_INTERPROCEDURAL_OPTIMIZATION)
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF)
  message(STATUS "Interprocedural optimization (IPO) disabled")
elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  # The php-src code base uses global register variables in Zend/zend_execute.c
  # and it is for now disabled when using GNU compiler due to the
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=68384 bug.
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF)

  message(
    STATUS
    "Interprocedural optimization (IPO) disabled (GCC global register "
    "variables)"
  )
else()
  include(CheckIPOSupported)
  check_ipo_supported(RESULT result)

  if(NOT result)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF)
    message(STATUS "Interprocedural optimization (IPO) disabled (unsupported)")
  elseif(result AND CMAKE_INTERPROCEDURAL_OPTIMIZATION)
    message(STATUS "Interprocedural optimization (IPO) enabled")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
  else()
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF)
    message(STATUS "Interprocedural optimization (IPO) disabled")
  endif()

  unset(result)
endif()
