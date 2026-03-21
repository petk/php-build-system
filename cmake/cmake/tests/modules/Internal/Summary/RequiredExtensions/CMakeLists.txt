cmake_minimum_required(VERSION 4.3...4.4)

project(PhpTestSummary LANGUAGES NONE)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../../../../../modules)

set(
  extensions
  bcmath
  bz2
  calendar
  com_dotnet
  ctype
  curl
  date
  dba
  dl_test
  dom
  enchant
)

set(
  disabled_extensions
  enchant
)

foreach(extension IN LISTS extensions)
  if(extension IN_LIST disabled_extensions)
    continue()
  endif()

  add_library(php_ext_${extension} INTERFACE)
  add_library(PHP::ext::${extension} ALIAS php_ext_${extension})

  set_property(GLOBAL APPEND PROPERTY PHP_ENABLED_EXTENSIONS ${extension})
endforeach()

set_property(GLOBAL PROPERTY PHP_ALL_EXTENSIONS ${extensions})

set_target_properties(
  php_ext_bcmath
  PROPERTIES PHP_REQUIRED_EXTENSIONS enchant
)

include(PHP/Internal/Summary)
php_summary_print()
