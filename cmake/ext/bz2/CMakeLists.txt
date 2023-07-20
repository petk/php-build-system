option(bz2 "Whether to enable the bz2 extension" OFF)

if(bz2)
  php_extension(NAME "bz2")
endif()
