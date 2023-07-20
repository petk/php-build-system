option(ffi "Whether to build the ffi extension" OFF)

if(ffi)
  php_extension(NAME ffi)

  add_library(ext_ffi
    ffi.c
    ffi_parser.c
  )
endif()
