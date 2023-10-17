include(CMakeDependentOption)

option(EXT_PSPELL "Whether to enable the pspell extension. GNU Aspell version 0.50.0 or higher required." OFF)

cmake_dependent_option(
  EXT_PSPELL_SHARED
  "Whether to build the pspell extension as shared object"
  OFF
  "EXT_PSPELL;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PSPELL)
  return()
endif()

if(EXT_PSPELL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

add_library(php_pspell ${_library_type}
  pspell.c
)

# Add -Wno-strict-prototypes as depends on user libs.
target_compile_options(php_pspell PRIVATE -Wno-strict-prototypes)

find_package(Aspell 0.50.0 REQUIRED)

target_link_libraries(php_pspell PRIVATE Aspell::Aspell)
