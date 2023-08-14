option(curl "Whether to enable the curl extension" OFF)

if(NOT curl)
  return()
endif()

php_extension(NAME "curl")

add_library(ext_curl
  interface.c
  multi.c
  share.c
  curl_file.c
)
