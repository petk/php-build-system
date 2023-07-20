option(ctype "Whether to enable the ctype extension" ON)

if(ctype)
  php_extension(NAME "ctype")

  add_library(ext_ctype
    ctype.c
  )

  target_include_directories(
    ext_ctype
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  )
endif()
