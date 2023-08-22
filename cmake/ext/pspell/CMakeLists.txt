option(pspell "Whether to enable the pspell extension. GNU Aspell version 0.50.0 or higher required." OFF)

if(NOT pspell)
  return()
endif()

string(TOLOWER ${pspell} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME pspell ${extension_library_type})

add_library(ext_pspell ${extension_library_type}
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
