include(CheckLibraryExists)

option(bz2 "Whether to enable the bz2 extension" OFF)

if(NOT bz2)
  return()
endif()

find_package(BZip2 1.0.0)

if(NOT BZIP2_FOUND)
  message(STATUS "Searching for BZip2 library in other locations")

  foreach(DIR "${bz2}" /usr/local /usr)
    if(EXISTS "${DIR}/include/bzlib.h")
      set(BZIP2_FOUND TRUE)
      set(BZIP2_INCLUDE_DIRS "${DIR}/include")
      set(BZIP2_LIBRARIES bz2)
    endif()
  endforeach()
endif()

if(NOT BZIP2_FOUND)
  message(FATAL_ERROR "BZip2 library not found. Please reinstall the BZip2 distribution")
endif()

check_library_exists(bz2 BZ2_bzerror "" HAVE_BZ2_LIB)

if(NOT HAVE_BZ2_LIB)
  message(FATAL_ERROR "bz2 module requires libbz2 >= 1.0.0")
endif()

string(TOLOWER ${bz2} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "bz2" ${extension_library_type})

add_library(ext_bz2 ${extension_library_type}
  bz2.c
  bz2_filter.c
)

target_include_directories(ext_bz2 PRIVATE "${BZIP2_INCLUDE_DIRS}")

target_link_libraries(ext_bz2 PRIVATE ${BZIP2_LIBRARIES})
