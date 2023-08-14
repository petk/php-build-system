option(bz2 "Whether to enable the bz2 extension" OFF)

if(NOT bz2)
  return()
endif()

php_extension(NAME "bz2")
