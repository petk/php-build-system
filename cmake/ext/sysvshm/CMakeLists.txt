include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_SYSVSHM "Enable the sysvshm extension" OFF)

add_feature_info(
  "ext/sysvshm"
  EXT_SYSVSHM
  "System V shared memory support"
)

cmake_dependent_option(
  EXT_SYSVSHM_SHARED
  "Build the sysvshm extension as a shared library"
  OFF
  "EXT_SYSVSHM;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_SYSVSHM)
  return()
endif()

if(EXT_SYSVSHM_SHARED)
  add_library(php_sysvshm SHARED)
else()
  add_library(php_sysvshm)
endif()

target_sources(
  php_sysvshm
  PRIVATE
    sysvshm.c
    sysvshm.stub.php
)
