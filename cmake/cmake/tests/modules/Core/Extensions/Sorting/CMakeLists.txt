cmake_minimum_required(VERSION 4.3...4.4)

project(PhpTestExtensionsSorting LANGUAGES NONE)

include(PHP/Core/Extensions)

set(
  extensions
  bcmath
  dom
  exif
  libxml
  mbstring
  pdo
  pdo_sqlite
)

foreach(extension IN LISTS extensions)
  add_library(php_ext_${extension} INTERFACE)
  add_library(PHP::ext::${extension} ALIAS php_ext_${extension})
endforeach()

set_target_properties(
  php_ext_pdo_sqlite
  PROPERTIES PHP_REQUIRED_EXTENSIONS pdo
)

set_target_properties(
  php_ext_dom
  PROPERTIES PHP_REQUIRED_EXTENSIONS libxml
)

set_target_properties(
  php_ext_exif
  PROPERTIES PHP_OPTIONAL_EXTENSIONS mbstring
)

set_target_properties(
  php_ext_exif
  PROPERTIES PHP_RECOMMENDED_EXTENSIONS foo
)

php_extensions_sort(extensions)

set(
  expected
  libxml
  mbstring
  pdo
  bcmath
  dom
  exif
  pdo_sqlite
)

if(NOT extensions STREQUAL expected)
  message(
    FATAL_ERROR
    "Expected order: ${expected}\n"
    "Actual order: ${extensions}"
  )
endif()
