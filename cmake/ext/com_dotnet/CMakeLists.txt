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

################################################################################
# Prepare tests
################################################################################

find_program(PHP_MIDL_EXECUTABLE midl)
mark_as_advanced(PHP_MIDL_EXECUTABLE)

if(PHP_MIDL_EXECUTABLE)
  add_library(php_ext_com_dotnet_comtest MODULE)

  target_sources(
    php_ext_com_dotnet_comtest
    PRIVATE
      tests/comtest/comtest.cpp
      tests/comtest/comtest.def
      ${CMAKE_CURRENT_BINARY_DIR}/tests/comtest/comtest_i.c
  )

  target_include_directories(
    php_ext_com_dotnet_comtest
    PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/tests/comtest
  )

  target_compile_options(php_ext_com_dotnet_comtest PRIVATE /nologo)
  target_link_libraries(php_ext_com_dotnet_comtest PRIVATE oleaut32)

  add_dependencies(php_ext_com_dotnet php_ext_com_dotnet_comtest)

  add_custom_command(
    OUTPUT
      tests/comtest/comtest.h
      tests/comtest/comtest_i.c
      tests/comtest/comtest.tlb
    COMMAND
      ${PHP_MIDL_EXECUTABLE}
      /nologo
      /h ${CMAKE_CURRENT_BINARY_DIR}/tests/comtest/comtest.h
      /iid ${CMAKE_CURRENT_BINARY_DIR}/tests/comtest/comtest_i.c
      /tlb ${CMAKE_CURRENT_BINARY_DIR}/tests/comtest/comtest.tlb
      ${CMAKE_CURRENT_SOURCE_DIR}/tests/comtest/comtest.idl
    COMMENT "[ext/com_dotnet] Generating comtest library sources"
    VERBATIM
    COMMAND_EXPAND_LISTS
  )

  add_custom_target(
    php_ext_com_dotnet_register_comtest
    COMMENT "[ext/com_dotnet] Adding keys to Windows Registry for tests"
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0"
        /d "PHP COM Test Library"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\0"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\0\\win32"
        /d "${CMAKE_CURRENT_BINARY_DIR}/tests/comtest/comtest.tlb"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\0\\win64"
        /d "${CMAKE_CURRENT_BINARY_DIR}/tests/comtest/comtest.tlb"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\FLAGS"
        /d 0 /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}\\1.0\\HELPDIR"
        /d "${CMAKE_CURRENT_BINARY_DIR}/tests/comtest"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\CLSID\\{B13FE324-D595-44C7-97D7-82CE20EDF878}"
        /d "PHP COM Test Document"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\CLSID\\{B13FE324-D595-44C7-97D7-82CE20EDF878}\\InprocServer32"
        /d "${CMAKE_CURRENT_BINARY_DIR}/tests/comtest/comtest.dll"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\PHPTest.Document"
        /d "PHP COM Test Document"
        /f > NUL
    COMMAND
      reg add
        "HKCU\\SOFTWARE\\Classes\\PHPTest.Document\\CLSID"
        /d "{B13FE324-D595-44C7-97D7-82CE20EDF878}"
        /f > NUL
    VERBATIM
  )

  add_custom_target(
    php_ext_com_dotnet_unregister_comtest
    COMMENT "[ext/com_dotnet] Removing keys from Windows Registry for tests"
    COMMAND reg delete "HKCU\\SOFTWARE\\Classes\\PHPTest.Document" /f > NUL
    COMMAND reg delete "HKCU\\SOFTWARE\\Classes\\CLSID\\{B13FE324-D595-44C7-97D7-82CE20EDF878}" /f > NUL
    COMMAND reg delete "HKCU\\SOFTWARE\\Classes\\TypeLib\\{AE8685BE-3758-4BDA-91DB-1459EBA24747}" /f > NUL
    VERBATIM
  )
endif()
