include(PHPFindPackage)
include(CMakeDependentOption)

option(EXT_ENCHANT "Whether to build the enchant extension" OFF)

cmake_dependent_option(EXT_ENCHANT_SHARED "Whether to build the enchant extension as shared object" OFF "EXT_ENCHANT;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_ENCHANT)
  return()
endif()

if(EXT_ENCHANT_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME enchant ${_library_type})

add_library(ext_enchant ${_library_type}
  enchant.c
)

php_find_package(NAME enchant-2 VERSION 2.0)

if(${enchant-2_FOUND})
  set(enchant_libraries "${enchant-2_LIBRARIES}")
  set(enchant_cflags "${enchant-2_CFLAGS}")
  set(HAVE_ENCHANT_GET_VERSION 1 CACHE INTERNAL "enchant_get_version since 1.6.0")
else()
  message(WARNING "libenchant-2 not found, trying with libenchant 1")

  php_find_package(NAME enchant VERSION 1.4.2)

  if(NOT ${enchant_FOUND})
    message(FATAL_ERROR "Enchant not found")
  endif()

  set(enchant_libraries ${enchant_LIBRARIES})
  set(enchant_cflags "${enchant_CFLAGS}")

  # enchant_get_version since 1.6.0.
  check_library_exists(enchant enchant_get_version "" HAVE_ENCHANT_GET_VERSION)

  # enchant_broker_set_param since 1.5.0 and removed in 2.x.
  check_library_exists(enchant enchant_broker_set_param "" HAVE_ENCHANT_BROKER_SET_PARAM)
endif()

target_link_libraries(ext_enchant PRIVATE ${enchant_libraries})
target_compile_options(ext_enchant PRIVATE ${enchant_cflags})
