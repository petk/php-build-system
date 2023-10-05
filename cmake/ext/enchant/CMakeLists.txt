include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_ENCHANT "Whether to build the enchant extension" OFF)

cmake_dependent_option(EXT_ENCHANT_SHARED "Whether to build the enchant extension as shared object" OFF "EXT_ENCHANT;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_ENCHANT)
  return()
endif()

if(EXT_ENCHANT_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "enchant" ${_library_type})

add_library(ext_enchant ${_library_type}
  enchant.c
)

find_package(ENCHANT 2.0)

if(ENCHANT_FOUND)
  set(HAVE_ENCHANT_GET_VERSION 1 CACHE INTERNAL "enchant_get_version since 1.6.0")
else()
  message(WARNING "enchant library 2 not found, trying with enchant 1")

  find_package(ENCHANT 1.4.2 REQUIRED)

  # enchant_get_version since 1.6.0.
  check_library_exists(${ENCHANT_LIBRARIES} enchant_get_version "" HAVE_ENCHANT_GET_VERSION)

  # enchant_broker_set_param since 1.5.0 and removed in 2.x.
  check_library_exists(${ENCHANT_LIBRARIES} enchant_broker_set_param "" HAVE_ENCHANT_BROKER_SET_PARAM)
endif()

if(ENCHANT_LIBRARIES)
  target_link_libraries(ext_enchant PRIVATE ${ENCHANT_LIBRARIES})
endif()

if(ENCHANT_INCLUDE_DIRS)
  target_include_directories(ext_enchant PRIVATE ${ENCHANT_INCLUDE_DIRS})
endif()
