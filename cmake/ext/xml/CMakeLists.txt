include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_XML "Enable the xml extension" ON)

add_feature_info(
  "ext/xml"
  EXT_XML
  "Support for parsing XML"
)

cmake_dependent_option(
  EXT_XML_SHARED
  "Build the xml extension as a shared library"
  OFF
  "EXT_XML;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_XML_EXPAT
  "Build xml extension with Expat support instead of libxml2"
  OFF
  "EXT_XML"
  OFF
)

if(NOT EXT_XML)
  return()
endif()

if(EXT_XML_SHARED)
  add_library(php_xml SHARED)
else()
  add_library(php_xml)
endif()

target_sources(
  php_xml
  PRIVATE
    xml.c
  PUBLIC
    FILE_SET HEADERS
      FILES
        expat_compat.h
        php_xml.h
)

target_compile_definitions(php_xml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(NOT EXT_LIBXML AND NOT EXT_XML_EXPAT)
  message(
    FATAL_ERROR
    "The xml extension requires either libxml extension or Expat library. Set "
    "EXT_LIBXML=ON or EXT_XML_EXPAT=ON"
  )
endif()

if(NOT EXT_XML_EXPAT)
  target_sources(php_xml PRIVATE compat.c)

  target_compile_definitions(
    php_xml
    PRIVATE
      $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<IN_LIST:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY;SHARED_LIBRARY>>>:LIBXML_STATIC>
  )

  include(Packages/LibXml2)

  set_package_properties(
    LibXml2
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the xml extension."
  )

  target_link_libraries(php_xml PRIVATE LibXml2::LibXml2)

  add_dependencies(php_xml php_libxml)
else()
  find_package(EXPAT)
  set_package_properties(
    EXPAT
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the xml extension."
  )

  target_link_libraries(php_xml PRIVATE EXPAT::EXPAT)

  set(HAVE_LIBEXPAT 1 CACHE INTERNAL "Whether libexpat is used")
endif()
