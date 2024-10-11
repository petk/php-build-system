# Available only for Windows system.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CheckIncludeFile)
include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_COM_DOTNET "Enable the com_dotnet extension" ON)

add_feature_info(
  "ext/com_dotnet"
  EXT_COM_DOTNET
  "Component Object Model (COM) and .NET support"
)

cmake_dependent_option(
  EXT_COM_DOTNET_SHARED
  "Build the com_dotnet extension as a shared library"
  OFF
  "EXT_COM_DOTNET;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_COM_DOTNET)
  return()
endif()

if(EXT_COM_DOTNET_SHARED)
  add_library(php_com_dotnet SHARED)
else()
  add_library(php_com_dotnet)
endif()

target_sources(
  php_com_dotnet
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
  php_com_dotnet
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
)

target_link_libraries(php_com_dotnet PRIVATE oleaut32)

check_include_file(mscoree.h HAVE_MSCOREE_H)
