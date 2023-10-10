include(CMakeDependentOption)

option(EXT_DOM "Whether to enable the DOM extension" ON)

cmake_dependent_option(EXT_DOM_SHARED "Whether to build the DOM extension as shared object" OFF "EXT_DOM;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_DOM)
  return()
endif()

if(NOT EXT_LIBXML)
  message(FATAL_ERROR "DOM extension requires LIBXML extension, set EXT_LIBXML=ON")
endif()

if(EXT_DOM_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "dom" ${_library_type})

add_library(php_dom ${_library_type}
  php_dom.c
  attr.c
  document.c
  domexception.c
  parentnode.c
  processinginstruction.c
  cdatasection.c
  documentfragment.c
  domimplementation.c
  element.c
  node.c
  characterdata.c
  documenttype.c
  entity.c
  nodelist.c
  text.c
  comment.c
  entityreference.c
  notation.c
  xpath.c
  dom_iterators.c
  namednodemap.c
)

target_link_libraries(php_dom PRIVATE php_libxml)

target_sources(
  php_dom
  PUBLIC FILE_SET dom_headers
  TYPE HEADERS
  FILES xml_common.h
)

install(
  TARGETS php_dom
  FILE_SET dom_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/dom
)
