#[=============================================================================[
# The zend_test extension

This extension provides additional support for testing PHP itself.

## Configuration options

### PHP_EXT_ZEND_TEST

* Default: `OFF`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_ZEND_TEST
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_ZEND_TEST "Enable the zend_test extension" ${PROJECT_IS_TOP_LEVEL})

add_feature_info(
  "ext/zend_test"
  PHP_EXT_ZEND_TEST
  "additional PHP build testing support"
)

if(NOT PHP_EXT_ZEND_TEST)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/Extension)
php_extension(zend_test)

if(PHP_EXT_ZEND_TEST STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
  add_library(php_ext_zend_test MODULE)
else()
  add_library(php_ext_zend_test OBJECT)
endif()

target_sources(
  php_ext_zend_test
  PRIVATE
    fiber.c
    fiber.stub.php
    iterators.c
    iterators.stub.php
    object_handlers.c
    object_handlers.stub.php
    observer.c
    test.c
    test.stub.php
    tmp_methods.stub.php
    zend_mm_custom_handlers.c
)

target_include_directories(php_ext_zend_test PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(
  php_ext_zend_test
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE
)

# Run at the end of the configuration. If libxml extension is enabled, link
# libxml library as headers are used.
if(PHP_SOURCE_DIR)
  set(dir ${PHP_SOURCE_DIR})
else()
  set(dir ${CMAKE_CURRENT_SOURCE_DIR})
endif()

cmake_language(DEFER DIRECTORY ${dir} CALL php_ext_zend_test_link_libxml)

function(php_ext_zend_test_link_libxml)
  if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    return()
  endif()

  # Check whether libxml extension is available.
  if(TARGET PHP::Interpreter)
    get_target_property(php_executable PHP::Interpreter LOCATION)
    execute_process(
      COMMAND ${php_executable} --ri libxml
      RESULT_VARIABLE code
      OUTPUT_QUIET
      ERROR_QUIET
    )

    if(NOT code EQUAL 0)
      return()
    endif()
  elseif(NOT TARGET PHP::ext::libxml)
    return()
  endif()

  include(PHP/Package/LibXml2)

  set_package_properties(
    LibXml2
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to add XML support to zend_test extension."
  )

  target_link_libraries(php_ext_zend_test PRIVATE LibXml2::LibXml2)
endfunction()
