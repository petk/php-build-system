include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_BCMATH "Enable the bcmath extension" OFF)

add_feature_info(
  "ext/bcmath"
  EXT_BCMATH
  "Basic Calculator (BC) style precision math functions support."
)

cmake_dependent_option(
  EXT_BCMATH_SHARED
  "Build the bcmath extension as a shared library"
  OFF
  "EXT_BCMATH;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_BCMATH)
  return()
endif()

if(EXT_BCMATH_SHARED)
  add_library(php_bcmath SHARED)
else()
  add_library(php_bcmath)
endif()

target_sources(
  php_bcmath
  PRIVATE
    bcmath.c
    libbcmath/src/add.c
    libbcmath/src/compare.c
    libbcmath/src/convert.c
    libbcmath/src/div.c
    libbcmath/src/divmod.c
    libbcmath/src/doaddsub.c
    libbcmath/src/floor_or_ceil.c
    libbcmath/src/init.c
    libbcmath/src/int2num.c
    libbcmath/src/nearzero.c
    libbcmath/src/neg.c
    libbcmath/src/num2long.c
    libbcmath/src/num2str.c
    libbcmath/src/raise.c
    libbcmath/src/raisemod.c
    libbcmath/src/recmul.c
    libbcmath/src/rmzero.c
    libbcmath/src/round.c
    libbcmath/src/sqrt.c
    libbcmath/src/str2num.c
    libbcmath/src/sub.c
    libbcmath/src/zero.c
)

target_compile_definitions(php_bcmath PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
