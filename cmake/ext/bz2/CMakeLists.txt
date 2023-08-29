include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_BZ2 "Whether to enable the BZ2 extension" OFF)

cmake_dependent_option(EXT_BZ2_SHARED "Whether to build the BZ2 extension as shared" OFF "EXT_BZ2;NOT BUILD_SHARED_LIBS" OFF)

if(EXT_BZ2)
  set(EXT_BZ2_DIR "" CACHE STRING "Additional path to the BZ2 library")
endif()

if(NOT EXT_BZ2)
  return()
endif()

if(EXT_BZ2_SHARED OR BUILD_SHARED_LIBS)
  set(_extension_library_type "SHARED")
endif()

php_extension(NAME "bz2" ${_extension_library_type})

add_library(ext_bz2 ${_extension_library_type}
  bz2.c
  bz2_filter.c
)

find_package(BZip2 1.0.0)

if(NOT BZIP2_FOUND)
  message(STATUS "Searching for BZip2 library in other locations")

  foreach(DIR "${EXT_BZ2_DIR}" /usr/local /usr)
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

target_include_directories(ext_bz2 PRIVATE "${BZIP2_INCLUDE_DIRS}")

target_link_libraries(ext_bz2 PRIVATE ${BZIP2_LIBRARIES})
