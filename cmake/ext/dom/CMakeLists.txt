option(dom "Whether to enable the DOM extension" ON)

if(NOT dom)
  return()
endif()

if(NOT libxml)
  message(FATAL_ERROR "DOM extension requires LIBXML extension, add -Dlibxml=ON")
endif()

string(TOLOWER ${dom} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "dom" ${extension_library_type})

add_library(ext_dom ${extension_library_type}
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

set_target_properties(ext_dom PROPERTIES PUBLIC_HEADER "xml_common.h")

target_link_libraries(ext_dom ext_libxml)
