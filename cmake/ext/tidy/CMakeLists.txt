include(CMakeDependentOption)

option(EXT_TIDY "Enable the tidy extension" OFF)

cmake_dependent_option(
  EXT_TIDY_SHARED
  "Build the tidy extension as a shared library"
  OFF
  "EXT_TIDY;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_TIDY)
  return()
endif()

if(EXT_TIDY_SHARED)
  add_library(php_tidy SHARED)
else()
  add_library(php_tidy)
endif()

target_sources(php_tidy PRIVATE
  tidy.c
)

# Add -Wno-ignored-qualifiers as this is an issue upstream.
target_compile_options(php_tidy PRIVATE -Wno-ignored-qualifiers)

target_compile_definitions(php_tidy PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(Tidy REQUIRED)

target_link_libraries(php_tidy PRIVATE Tidy::Tidy)
