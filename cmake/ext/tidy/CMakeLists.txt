include(CMakeDependentOption)

option(EXT_TIDY "Whether to enable the tidy extension" OFF)

cmake_dependent_option(EXT_TIDY_SHARED "Whether to build the tidy extension as shared object" OFF "EXT_TIDY;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_TIDY)
  return()
endif()

if(EXT_TIDY_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "tidy" ${_library_type})

add_library(ext_tidy ${_library_type}
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
