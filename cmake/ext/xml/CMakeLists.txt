option(xml "Whether to enable the XML extension" ON)

option(xml_expat "Whether to build with expat support instead of libxml2" OFF)

if(xml)
  string(TOLOWER ${xml} extension_lower)
  set(extension_library_type "STATIC")
  if(extension_lower STREQUAL "shared")
    set(extension_library_type "SHARED")
  endif()

  php_extension(NAME "xml" ${extension_library_type})

  add_library(ext_xml ${extension_library_type}
    xml.c
  )

  if(NOT xml_expat AND NOT libxml)
    message(FATAL_ERROR "XML extension requires LIBXML extension, add -Dlibxml=ON")
  endif()

  if(NOT xml_expat)
    target_sources(ext_xml PRIVATE compat.c)

    target_link_libraries(ext_xml ext_libxml)
  else()
    find_package(EXPAT REQUIRED GLOBAL)

    if(NOT EXPAT_FOUND)
      message(FATAL_ERROR "Expat library not found")
    endif()

    set(HAVE_LIBEXPAT 1 CACHE INTERNAL "Whether libexpat is used")

    target_link_libraries(ext_xml PUBLIC "${EXPAT_LIBRARIES}")
    target_include_directories(ext_xml PUBLIC "${EXPAT_INCLUDE_DIRS}")
  endif()

  file(GLOB XML_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
  set_target_properties(ext_xml PROPERTIES PUBLIC_HEADER "${XML_HEADER_FILES}")

  target_compile_definitions(ext_xml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)
endif()
