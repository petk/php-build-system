option(shmop "Whether to enable the shmop extension" OFF)

if(shmop)
  string(TOLOWER ${shmop} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME "shmop" ${extension_library_type})

  add_library(ext_shmop ${extension_library_type}
    shmop.c
  )
endif()
