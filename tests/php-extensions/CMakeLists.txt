include(../../cmake/cmake/modules/PHP/Extensions.cmake)

php_extensions_add(ext)

get_cmake_property(php_extensions PHP_EXTENSIONS)

set(sorted
  ext_3
  ext_2
  ext_1
)

if(NOT php_extensions EQUAL sorted)
  message(FATAL_ERROR "not sorted")
endif()
