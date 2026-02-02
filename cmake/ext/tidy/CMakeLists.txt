#[=============================================================================[
# The tidy extension

This extension provides support for Tidy HTML utility support to handle HTML,
XHTML and XML documents.

## Configuration options

### PHP_EXT_TIDY

* Default: `OFF`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_TIDY_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_TIDY
  LANGUAGES C
)

include(CheckIncludeFiles)
include(CheckSourceCompiles)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)

option(PHP_EXT_TIDY "Enable the tidy extension")

add_feature_info(
  "ext/tidy"
  PHP_EXT_TIDY
  "HTML, XHTML and XML correction support"
)

cmake_dependent_option(
  PHP_EXT_TIDY_SHARED
  "Build the tidy extension as a shared library"
  OFF
  PHP_EXT_TIDY
  OFF
)

if(NOT PHP_EXT_TIDY)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(tidy)

if(PHP_EXT_TIDY_SHARED)
  add_library(php_ext_tidy MODULE)
else()
  add_library(php_ext_tidy OBJECT)
endif()

target_sources(
  php_ext_tidy
  PRIVATE
    tidy.c
    tidy.stub.php
)

get_target_property(type php_ext_tidy TYPE)
if(
  CMAKE_SYSTEM_NAME STREQUAL "Windows"
  AND TARGET php_sapi
  AND NOT type MATCHES "^(MODULE|SHARED)_LIBRARY$"
)
  target_sources(php_sapi INTERFACE php_tidy.def)
endif()

# Add -Wno-ignored-qualifiers as this is an issue upstream. Fixed in tidy-html5
# 5.7.20. See: https://github.com/htacg/tidy-html5/issues/866
if(Tidy_VERSION VERSION_LESS 5.7.20)
  php_check_compiler_flag(
    C
    -Wno-ignored-qualifiers
    PHP_HAS_WNO_IGNORED_QUALIFIERS_C
  )
  if(PHP_HAS_WNO_IGNORED_QUALIFIERS_C)
    target_compile_options(php_ext_tidy PRIVATE -Wno-ignored-qualifiers)
  endif()
endif()

target_compile_definitions(php_ext_tidy PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

find_package(Tidy)
set_package_properties(
  Tidy
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the tidy extension."
)

target_link_libraries(php_ext_tidy PRIVATE Tidy::Tidy)

if(TARGET Tidy::Tidy)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES Tidy::Tidy)

    # Check for <tidybuffio.h> (as opposed to the legacy <buffio.h>), which
    # indicates that the found library is tidy-html5 and not the legacy
    # htmltidy. The two are compatible, except the legacy doesn't have the
    # <tidybuffio.h> header.
    check_include_files(tidybuffio.h PHP_EXT_TIDY_HAVE_TIDYBUFFIO_H)
    set(HAVE_TIDYBUFFIO_H ${PHP_EXT_TIDY_HAVE_TIDYBUFFIO_H})

    check_symbol_exists(
      tidyOptGetDoc
      "${Tidy_HEADER}"
      PHP_EXT_TIDY_HAVE_TIDYOPTGETDOC
    )
    set(HAVE_TIDYOPTGETDOC ${PHP_EXT_TIDY_HAVE_TIDYOPTGETDOC})

    check_symbol_exists(
      tidyReleaseDate
      "${Tidy_HEADER}"
      PHP_EXT_TIDY_HAVE_TIDYRELEASEDATE
    )
    set(HAVE_TIDYRELEASEDATE ${PHP_EXT_TIDY_HAVE_TIDYRELEASEDATE})

    # The tidyOptGetCategory() function (added in tidy-html5 5.4.0) is only
    # usable in PHP at the time of writing due to unconditional usage of the
    # TidyInternalCategory enumeration (added in tidy-html5 5.6.0). The tidyp
    # fork, doesn't have tidyOptGetCategory().
    check_source_compiles(C [[
      #include <tidy.h>
      int main(void)
      {
        TidyDoc doc = tidyCreate();
        TidyOption option = tidyGetOptionByName(doc, "<bad>");
        Bool v = (tidyOptGetCategory(option) == TidyInternalCategory);
        (void)v;
        tidyRelease(doc);
        return 0;
      }
    ]] PHP_EXT_TIDY_HAVE_TIDYOPTGETCATEGORY)
    set(HAVE_TIDYOPTGETCATEGORY ${PHP_EXT_TIDY_HAVE_TIDYOPTGETCATEGORY})
  cmake_pop_check_state()

  if(Tidy_HEADER STREQUAL "tidy.h")
    set(HAVE_TIDY_H TRUE)
  elseif(Tidy_HEADER STREQUAL "tidyp.h")
    set(HAVE_TIDYP_H TRUE)
  endif()
endif()

set(HAVE_TIDY TRUE)

configure_file(cmake/config.h.in config.h)
