#[=============================================================================[
# The com_dotnet extension

Configure the `com_dotnet` extension.

This extension provides the Component Object Model (COM) and .NET support.

> [!NOTE]
> This extension is available only when the target system is Windows.

## PHP_EXT_COM_DOTNET

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_COM_DOTNET_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionComDotnet
  LANGUAGES C
)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckIncludeFiles)
include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_COM_DOTNET "Enable the com_dotnet extension" ON)

add_feature_info(
  "ext/com_dotnet"
  PHP_EXT_COM_DOTNET
  "Component Object Model (COM) and .NET support"
)

cmake_dependent_option(
  PHP_EXT_COM_DOTNET_SHARED
  "Build the com_dotnet extension as a shared library"
  OFF
  "PHP_EXT_COM_DOTNET;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_COM_DOTNET)
  return()
endif()

if(PHP_EXT_COM_DOTNET_SHARED)
  add_library(php_ext_com_dotnet MODULE)
else()
  add_library(php_ext_com_dotnet)
endif()

target_sources(
  php_ext_com_dotnet
  PRIVATE
    com_com.c
    com_dotnet.c
    com_extension.c
    com_extension.stub.php
    com_handlers.c
    com_iterator.c
    com_misc.c
    com_olechar.c
    com_persist.c
    com_persist.stub.php
    com_saproxy.c
    com_typeinfo.c
    com_variant.c
    com_wrapper.c
)

target_compile_definitions(
  php_ext_com_dotnet
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

target_link_libraries(php_ext_com_dotnet PRIVATE oleaut32)

check_include_files(mscoree.h HAVE_MSCOREE_H)

set(HAVE_COM_DOTNET TRUE)

configure_file(cmake/config.h.in config.h)
