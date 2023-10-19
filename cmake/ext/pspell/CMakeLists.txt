include(CMakeDependentOption)

option(EXT_PSPELL "Enable the pspell extension (GNU Aspell version 0.50.0 or higher required)" OFF)

cmake_dependent_option(
  EXT_PSPELL_SHARED
  "Build the pspell extension as a shared library"
  OFF
  "EXT_PSPELL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PSPELL)
  return()
endif()

if(EXT_PSPELL_SHARED)
  set(_type "SHARED")
endif()

add_library(php_pspell ${_type}
  pspell.c
)

# Add -Wno-strict-prototypes as depends on user libs.
check_compiler_flag(C -Wno-strict-prototypes HAVE_WNO_STRICT_PROTOTYPES_C)
if(HAVE_WNO_STRICT_PROTOTYPES_C)
  target_compile_options(php_pspell
    PRIVATE "$<$<COMPILE_LANGUAGE:C>:-Wno-strict-prototypes>"
  )
endif()

find_package(Aspell 0.50.0 REQUIRED)

target_link_libraries(php_pspell PRIVATE Aspell::Aspell)
