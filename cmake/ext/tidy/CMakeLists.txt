include(CheckCompilerFlag)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_TIDY "Enable the tidy extension" OFF)

add_feature_info(
  "ext/tidy"
  EXT_TIDY
  "Tidy HTML utility support to handle HTML, XHTML and XML documents."
)

cmake_dependent_option(
  EXT_TIDY_SHARED
  "Build the tidy extension as a shared library"
  OFF
  "EXT_TIDY;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_TIDY)
  return()
endif()

if(EXT_TIDY_SHARED)
  add_library(php_tidy SHARED)
else()
  add_library(php_tidy)
endif()

target_sources(
  php_tidy
  PRIVATE
    php_tidy.def
    tidy.c
)

# Add -Wno-ignored-qualifiers as this is an issue upstream.
check_compiler_flag(C -Wno-ignored-qualifiers HAVE_WNO_IGNORED_QUALIFIERS_C)
if(HAVE_WNO_IGNORED_QUALIFIERS_C)
  target_compile_options(php_tidy PRIVATE -Wno-ignored-qualifiers)
endif()

target_compile_definitions(php_tidy PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

find_package(Tidy)
set_package_properties(
  Tidy
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the tidy extension."
)

target_link_libraries(php_tidy PRIVATE Tidy::Tidy)
