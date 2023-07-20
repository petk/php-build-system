option(exif "Whether to enable exif (metadata from images) extension" OFF)

if(exif)
  php_extension(NAME exif)

  add_library(ext_exif
    exif.c
  )
endif()
