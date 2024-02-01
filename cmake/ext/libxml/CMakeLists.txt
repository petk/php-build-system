include(FeatureSummary)

option(EXT_LIBXML "Enable the libxml extension" ON)

add_feature_info(
  "ext/libxml"
  EXT_LIBXML
  "Support for XML parser and toolkit libxml. Can be built only as static."
)

if(NOT EXT_LIBXML)
  return()
endif()

# This extension can be built only as a STATIC library.
add_library(php_libxml STATIC)

target_sources(
  php_libxml
  PRIVATE
    libxml.c
    php_libxml2.def
  PUBLIC
    FILE_SET HEADERS
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        php_libxml.h
)

target_compile_definitions(
  php_libxml
  PRIVATE
    ZEND_ENABLE_STATIC_TSRMLS_CACHE=1
    $<$<PLATFORM_ID:Windows>:LIBXML_STATIC;LIBXML_STATIC_FOR_DLL>
)

find_package(LibXml2 ${PHP_LIBXML2_MIN_VERSION})
set_package_properties(
  LibXml2
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the libxml extension."
)

# HAVE_WIN32_THREADS is not needed on newer libxml2 versions anymore.
if(LIBXML2_VERSION_STRING VERSION_LESS 2.10)
  target_compile_definitions(
    php_libxml PRIVATE
    $<$<PLATFORM_ID:Windows>:HAVE_WIN32_THREADS>
  )
endif()

target_link_libraries(php_libxml PUBLIC LibXml2::LibXml2)

install(
  TARGETS php_libxml
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
