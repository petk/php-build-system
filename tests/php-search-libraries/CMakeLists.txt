include(../../cmake/cmake/modules/PHP/SearchLibraries.cmake)

# Check that LIBRARY_VARIABLE is cleared of any existing value.
set(library "foobar")
php_search_libraries(
  atoi
  HAVE_ATOI
  HEADERS stdlib.h
  LIBRARY_VARIABLE library
)

if(NOT library STREQUAL "")
  message(FATAL_ERROR "failed")
endif()
