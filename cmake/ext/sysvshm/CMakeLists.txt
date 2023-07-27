option(sysvshm "Whether to enable the sysvshm extension" OFF)

if(sysvshm)
  string(TOLOWER ${sysvshm} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME "sysvshm" ${extension_library_type})

  add_library(ext_sysvshm ${extension_library_type}
    sysvshm.c
  )
endif()
