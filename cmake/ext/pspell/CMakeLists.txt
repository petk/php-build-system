include(CMakeDependentOption)

option(EXT_PSPELL "Whether to enable the pspell extension. GNU Aspell version 0.50.0 or higher required." OFF)

cmake_dependent_option(EXT_PSPELL_SHARED "Whether to build the pspell extension as shared object" OFF "EXT_PSPELL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_PSPELL)
  return()
endif()

if(EXT_PSPELL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "pspell" ${_library_type})

add_library(ext_pspell ${_library_type}
  pspell.c
)

# Add -Wno-strict-prototypes as depends on user libs.
target_compile_options(ext_pspell PRIVATE -Wno-strict-prototypes)

find_package(ASPELL 0.50.0 REQUIRED)

if(ASPELL_LIBRARIES)
  target_link_libraries(ext_pspell PRIVATE ${ASPELL_LIBRARIES})
endif()

if(ASPELL_INCLUDE_DIRS)
  target_include_directories(ext_pspell PRIVATE ${ASPELL_INCLUDE_DIRS})
endif()
