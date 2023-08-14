option(com_dotnet "Whether to enable the com_dotnet extension" OFF)

if(NOT com_dotnet)
  return()
endif()

php_extension(NAME "com_dotnet")
