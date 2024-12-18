#[=============================================================================[
Enable and configure tests.
#]=============================================================================]

if(NOT TARGET PHP::SAPI::cli)
  return()
endif()

enable_testing()

block()
  include(ProcessorCount)
  processorcount(processors)

  if(NOT processors EQUAL 0)
    set(parallel -j${processors})
  endif()

  get_property(extensions GLOBAL PROPERTY PHP_EXTENSIONS)
  foreach(extension IN LISTS extensions)
    get_target_property(type PHP::ext::${extension} TYPE)
    if(type MATCHES "^(MODULE|SHARED)_LIBRARY$")
      get_target_property(isZendExtension PHP::ext::${extension} PHP_ZEND_EXTENSION)
      if(isZendExtension)
        list(APPEND options -d zend_extension=${extension})
      elseif(NOT extension STREQUAL "dl_test")
        list(APPEND options -d extension=${extension})
      endif()
    endif()
  endforeach()

  add_test(
    NAME PHP
    COMMAND
      PHP::SAPI::cli
        -n
        -d open_basedir=
        -d output_buffering=0
        -d memory_limit=-1
        run-tests.php
          -n
          -d extension_dir=${PHP_BINARY_DIR}/modules
          --show-diff
          ${options}
          ${parallel}
          -q
    WORKING_DIRECTORY ${PHP_SOURCE_DIR}
  )
endblock()
