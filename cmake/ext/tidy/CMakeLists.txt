project(
  PhpExtensionTidy
  LANGUAGES C
)

include(CheckLibraryExists)
include(CMakeDependentOption)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(EXT_TIDY "Enable the tidy extension" OFF)

add_feature_info(
  "ext/tidy"
  EXT_TIDY
  "Tidy HTML utility support to handle HTML, XHTML and XML documents"
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
    tidy.stub.php
)

# Add -Wno-ignored-qualifiers as this is an issue upstream. Fixed in tidy-html5
# 5.7.20. See: https://github.com/htacg/tidy-html5/issues/866
if(Tidy_VERSION VERSION_LESS 5.7.20)
  php_check_compiler_flag(
    C
    -Wno-ignored-qualifiers
    HAVE_WNO_IGNORED_QUALIFIERS_C
  )
  if(HAVE_WNO_IGNORED_QUALIFIERS_C)
    target_compile_options(php_tidy PRIVATE -Wno-ignored-qualifiers)
  endif()
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

if(TARGET Tidy::Tidy)
  check_library_exists(Tidy::Tidy tidyOptGetDoc "" HAVE_TIDYOPTGETDOC)
  check_library_exists(Tidy::Tidy tidyReleaseDate "" HAVE_TIDYRELEASEDATE)
endif()

set(HAVE_TIDY 1)

configure_file(config.cmake.h.in config.h @ONLY)
