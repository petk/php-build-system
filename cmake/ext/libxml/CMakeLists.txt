include(FeatureSummary)

option(
  EXT_LIBXML
  "Enable the libxml extension (can be built only statically)"
  ON
)

add_feature_info(
  "ext/libxml"
  EXT_LIBXML
  "Support for XML parser and toolkit libxml"
)

if(NOT EXT_LIBXML)
  return()
endif()

# Extension cannot be built as a SHARED library.
add_library(php_libxml STATIC)

target_sources(
  php_libxml
  PRIVATE
    libxml.c
    libxml.stub.php
    php_libxml2.def
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_libxml.h
)

target_compile_definitions(
  php_libxml
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<PLATFORM_ID:Windows>:LIBXML_STATIC;LIBXML_STATIC_FOR_DLL>
)

include(Packages/LibXml2)

set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the libxml extension."
)

# HAVE_WIN32_THREADS is not needed on newer libxml2 versions anymore.
if(LIBXML2_VERSION_STRING VERSION_LESS 2.10)
  target_compile_definitions(
    php_libxml
    PRIVATE
      $<$<PLATFORM_ID:Windows>:HAVE_WIN32_THREADS>
  )
endif()

target_link_libraries(php_libxml PUBLIC LibXml2::LibXml2)
