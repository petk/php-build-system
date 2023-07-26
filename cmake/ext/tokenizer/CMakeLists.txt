option(tokenizer "Whether to enable the tokenizer extension" ON)

if(tokenizer)
  string(TOLOWER ${tokenizer} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME "tokenizer" ${extension_library_type})

  add_library(ext_tokenizer ${extension_library_type}
    tokenizer.c
    tokenizer_data.c
  )

  target_include_directories(
    ext_tokenizer
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
  )
endif()

# TODO: Fix this.
add_dependencies(ext_tokenizer Zend)
