include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_ENCHANT "Enable the enchant extension" OFF)

add_feature_info(
  "ext/enchant"
  EXT_ENCHANT
  "PHP binding for the Enchant spelling library"
)

cmake_dependent_option(
  EXT_ENCHANT_SHARED
  "Build the enchant extension as a shared library"
  OFF
  "EXT_ENCHANT;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_ENCHANT)
  return()
endif()

if(EXT_ENCHANT_SHARED)
  add_library(php_enchant SHARED)
else()
  add_library(php_enchant)
endif()

target_sources(
  php_enchant
  PRIVATE
    enchant.c
    enchant.stub.php
)

find_package(Enchant 2.0)
set_package_properties(
  Enchant
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the enchant extension."
)

if(Enchant_FOUND)
  set(
    HAVE_ENCHANT_GET_VERSION 1
    CACHE INTERNAL "enchant_get_version since 1.6.0"
  )
else()
  message(WARNING "Library Enchant 2 not found, trying with Enchant 1")

  find_package(Enchant 1.4.2)

  if(TARGET Enchant::Enchant)
    # enchant_get_version since 1.6.0.
    check_library_exists(
      Enchant::Enchant
      enchant_get_version
      ""
      HAVE_ENCHANT_GET_VERSION
    )

    # enchant_broker_set_param since 1.5.0 and removed in 2.x.
    check_library_exists(
      Enchant::Enchant
      enchant_broker_set_param
      ""
      HAVE_ENCHANT_BROKER_SET_PARAM
    )
  endif()
endif()

target_link_libraries(php_enchant PRIVATE Enchant::Enchant)
