option(ctype "Whether to enable the ctype extension" ON)

if(ctype)
  project(ext_ctype VERSION ${CMAKE_PROJECT_VERSION} DESCRIPTION "Ctype PHP extension")

  string(TOLOWER ${ctype} ctype_lower)
  set(ctype_library_type "STATIC")
  if(ctype_lower STREQUAL "shared")
    set(ctype_library_type "SHARED")
  endif()

  php_extension(NAME "ctype" ${ctype_library_type})

  add_library(ext_ctype ${ctype_library_type}
    ctype.c
  )

  target_include_directories(
    ext_ctype
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  )
endif()
