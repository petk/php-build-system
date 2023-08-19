option(gmp "Whether to enable the gmp extension" OFF)

if(NOT gmp)
  return()
endif()

string(TOLOWER ${gmp} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "gmp" ${extension_library_type})

add_library(ext_gmp ${extension_library_type}
  gmp.c
)

target_compile_definitions(ext_gmp PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

set_target_properties(ext_gmp PROPERTIES PUBLIC_HEADER "php_gmp_int.h")

find_package(GMP 4.2 REQUIRED)

if(GMP_LIBRARIES)
  target_link_libraries(ext_gmp PRIVATE ${GMP_LIBRARIES})
endif()

if(GMP_INCLUDE_DIRS)
  target_include_directories(ext_gmp PRIVATE ${GMP_INCLUDE_DIRS})
endif()
