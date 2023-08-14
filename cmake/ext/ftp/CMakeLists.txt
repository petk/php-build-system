option(ftp "Whether to enable the ftp extension" OFF)

if(NOT ftp)
  return()
endif()

php_extension(NAME ftp)

add_library(ext_ftp
  php_ftp.c
  ftp.c
)
