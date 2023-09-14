include(CMakeDependentOption)

option(EXT_DOM "Whether to enable the DOM extension" ON)

cmake_dependent_option(EXT_DOM_SHARED "Whether to build the DOM extension as shared object" OFF "EXT_DOM;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_DOM)
  return()
endif()

if(NOT EXT_LIBXML)
  message(FATAL_ERROR "DOM extension requires LIBXML extension, add EXT_LIBXML=ON")
endif()

if(EXT_DOM_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "dom" ${_library_type})

add_library(ext_dom ${_library_type}
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

target_link_libraries(ext_dom PRIVATE ext_libxml)

target_sources(
  ext_dom
  PUBLIC FILE_SET ext_dom_headers
  TYPE HEADERS
  FILES xml_common.h
)

install(
  TARGETS ext_dom
  FILE_SET ext_dom_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/dom
)
