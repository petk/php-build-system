include(CheckLibraryExists)
include(CMakeDependentOption)

option(EXT_ENCHANT "Whether to build the enchant extension" OFF)

cmake_dependent_option(
  EXT_ENCHANT_SHARED
  "Whether to build the enchant extension as shared object"
  OFF
  "EXT_ENCHANT;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ENCHANT)
  return()
endif()

if(EXT_ENCHANT_SHARED)
  set(_type "SHARED")
endif()

add_library(php_enchant ${_type}
  enchant.c
)

find_package(Enchant 2.0)

if(Enchant_FOUND)
  set(HAVE_ENCHANT_GET_VERSION 1 CACHE INTERNAL "enchant_get_version since 1.6.0")
else()
  message(WARNING "Library Enchant 2 not found, trying with Enchant 1")

  find_package(Enchant 1.4.2 REQUIRED)

  # enchant_get_version since 1.6.0.
  check_library_exists(Enchant::Enchant enchant_get_version "" HAVE_ENCHANT_GET_VERSION)

  # enchant_broker_set_param since 1.5.0 and removed in 2.x.
  check_library_exists(Enchant::Enchant enchant_broker_set_param "" HAVE_ENCHANT_BROKER_SET_PARAM)
endif()

target_link_libraries(php_enchant PRIVATE Enchant::Enchant)
