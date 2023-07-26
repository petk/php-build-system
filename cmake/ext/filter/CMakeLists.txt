option(filter "Whether to enable the filter extension" ON)

if(filter)
  string(TOLOWER ${filter} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME filter ${extension_library_type})

  add_library(ext_filter ${extension_library_type}
    filter.c
    sanitizing_filters.c
    logical_filters.c
    callback_filter.c
  )

  target_include_directories(
    ext_filter
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  )

  target_compile_definitions(ext_filter PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

  set_target_properties(ext_filter PROPERTIES PUBLIC_HEADER "php_filter.h")
endif()
