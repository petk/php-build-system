# Available only for Windows system.
if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

include(CMakeDependentOption)

option(EXT_COM_DOTNET "Whether to enable the com_dotnet extension" OFF)

if(NOT EXT_COM_DOTNET)
  return()
endif()

php_extension(NAME "com_dotnet")

add_library(php_com_dotnet
  com_com.c
  com_dotnet.c
  com_extension.c
  com_handlers.c
  com_iterator.c
  com_misc.c
  com_olechar.c
  com_typeinfo.c
  com_variant.c
  com_wrapper.c
  com_saproxy.c
  com_persist.c
)

target_compile_definitions(php_com_dotnet PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
