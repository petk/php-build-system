#[=============================================================================[
# The com_dotnet extension

Configure the `com_dotnet` extension.

This extension provides the Component Object Model (COM) and .NET support.

> [!NOTE]
> This extension is available only when the target system is Windows.

## Requirements

To build this extension, Windows SDK needs to be installed, which includes
the COM support.

To enable also the .NET support in this extension (e.g., the `dotnet` PHP
class), the .NET framework needs to be installed, which provides the
`<mscoree.h>` header. This can be done in several ways:

* in Visual Studio by installing the .NET desktop development workload
* in Visual Studio by installing the .NET framework 4.x component only
* Download and install
  [.NET framework](https://dotnet.microsoft.com/en-us/download/dotnet-framework)
  manually.

The .NET version 5 and later are not supported as they have removed the
`<mscoree.h>` API.

## Configuration options

### PHP_EXT_COM_DOTNET

* Default: `ON`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_COM_DOTNET_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.

### PHP_EXT_COM_DOTNET_ENABLE_DOTNET

* Default: `ON`
* Values: `ON|OFF`

Enables the .NET Framework support.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_COM_DOTNET
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
  PHP_EXT_COM_DOTNET
  OFF
)

cmake_dependent_option(
  PHP_EXT_COM_DOTNET_ENABLE_DOTNET
  "Enable .NET support"
  ON
  PHP_EXT_COM_DOTNET
  OFF
)

if(NOT PHP_EXT_COM_DOTNET)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(com_dotnet)

if(PHP_EXT_COM_DOTNET_SHARED)
  add_library(php_ext_com_dotnet MODULE)
else()
  add_library(php_ext_com_dotnet OBJECT)
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

if(PHP_EXT_COM_DOTNET_ENABLE_DOTNET)
  check_include_files(mscoree.h PHP_EXT_COM_DOTNET_HAVE_MSCOREE_H)

  if(NOT PHP_EXT_COM_DOTNET_HAVE_MSCOREE_H)
    message(
      FATAL_ERROR
      "<mscoree.h> not found. Please install the .NET Framework or disable the "
      ".NET support with by setting 'PHP_EXT_COM_DOTNET_ENABLE_DOTNET' to "
      "'OFF'."
    )
  endif()

  set(HAVE_MSCOREE_H TRUE)
endif()

set(HAVE_COM_DOTNET TRUE)

configure_file(cmake/config.h.in config.h)
