option(com_dotnet "Whether to enable the com_dotnet extension" OFF)

if(NOT com_dotnet)
  return()
endif()

php_extension(NAME "com_dotnet")

add_library(ext_com_dotnet
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

target_compile_definitions(ext_com_dotnet PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
