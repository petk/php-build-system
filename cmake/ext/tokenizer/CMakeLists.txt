include(CMakeDependentOption)

option(EXT_TOKENIZER "Whether to enable the tokenizer extension" ON)

cmake_dependent_option(EXT_TOKENIZER_SHARED "Whether to build the tokenizer extension as shared object" OFF "EXT_TOKENIZER;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_TOKENIZER)
  return()
endif()

if(EXT_TOKENIZER_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "tokenizer" ${_library_type})

add_library(ext_tokenizer ${_library_type}
  tokenizer.c
  tokenizer_data.c
)

# The tokenizer depends on the created Zend language scanner definitions header.
# TODO: Check if this can be moved elsewhere.
add_dependencies(ext_tokenizer Zend)
