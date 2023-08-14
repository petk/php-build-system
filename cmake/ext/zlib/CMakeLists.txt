option(zlib "Whether to enable the zlib extension (requires zlib >= 1.2.0.4)" OFF)

if(NOT zlib)
  return()
endif()

php_find_package(NAME zlib VERSION 1.2.0.4)

string(TOLOWER ${zlib} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME zlib ${extension_library_type})

add_library(ext_zlib ${extension_library_type}
  zlib.c
  zlib_fopen_wrapper.c
  zlib_filter.c
)

target_compile_definitions(ext_zlib PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_libraries(ext_zlib PRIVATE ${zlib_LIBRARIES})
target_compile_options(ext_zlib PRIVATE ${zlib_CFLAGS})
