option(exif "Whether to enable exif (metadata from images) support" OFF)

if(exif)
  project(ext_exif VERSION ${CMAKE_PROJECT_VERSION} DESCRIPTION "Exif PHP extension")

  string(TOLOWER ${exif} exif_lower)
  set(exif_library_type "STATIC")
  if(exif_lower STREQUAL "shared")
    set(exif_library_type "SHARED")
  endif()

  php_extension(NAME exif ${exif_library_type})

  add_library(ext_exif ${exif_library_type}
    exif.c
  )

  target_include_directories(
    ext_exif
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  )

  target_compile_definitions(ext_exif PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
endif()
