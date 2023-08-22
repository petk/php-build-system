option(tidy "Whether to enable the tidy extension" OFF)

if(NOT tidy)
  return()
endif()

string(TOLOWER ${tidy} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "tidy" ${extension_library_type})

add_library(ext_tidy ${extension_library_type}
  tidy.c
)

# Add -Wno-ignored-qualifiers as this is an issue upstream.
target_compile_options(ext_tidy PRIVATE -Wno-ignored-qualifiers)

target_compile_definitions(ext_tidy PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(TIDY REQUIRED)

if(TIDY_LIBRARIES)
  target_link_libraries(ext_tidy PRIVATE ${TIDY_LIBRARIES})
endif()

if(TIDY_INCLUDE_DIRS)
  target_include_directories(ext_tidy PRIVATE ${TIDY_INCLUDE_DIRS})
endif()
