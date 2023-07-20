option(com_dotnet "Whether to enable the com_dotnet extension" OFF)

if(com_dotnet)
  php_extension(NAME "com_dotnet")
endif()
