if(NOT TARGET PHP::sapi::cli AND NOT TARGET PHP::Interpreter)
  return()
endif()

if(PHP_SOURCE_DIR)
  set(dir ${PHP_SOURCE_DIR})
else()
  set(dir ${PROJECT_SOURCE_DIR})
endif()

cmake_language(DEFER DIRECTORY ${dir} CALL php_ext_phar_add_tests)

function(php_ext_phar_add_tests)
  # Check whether building a self-contained extension or in php-src.
  if(TARGET PHP::Interpreter)
    set(php_executable "PHP::Interpreter")
    set(extensions phar)
  else()
    set(php_executable "PHP::sapi::cli")
    set(extensions bz2 openssl phar zlib)
  endif()

  # Configure phar and dependent extensions.
  set(php_options "")

  foreach(extension IN LISTS extensions)
    if(NOT TARGET PHP::ext::${extension})
      continue()
    endif()

    get_target_property(type PHP::ext::${extension} TYPE)
    if(type STREQUAL "MODULE_LIBRARY")
      list(
        APPEND
        php_options
        -d extension=${PROJECT_BINARY_DIR}/modules/$<CONFIG>/${extension}${CMAKE_SHARED_MODULE_SUFFIX}
      )
    endif()
  endforeach()

  add_test(
    NAME PhpExtPharVersion
    COMMAND
      ${php_executable}
      ${php_options}
      ${PHP_EXT_PHAR_BINARY_DIR}/phar.phar
      version
  )

  set_tests_properties(
    PhpExtPharVersion
    PROPERTIES
      PASS_REGULAR_EXPRESSION "PHP Version:[ ]+${PHP_VERSION}"
  )
endfunction()
