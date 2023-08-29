include(CMakeDependentOption)

option(EXT_SIMPLEXML "Whether to enable the simplexml extension" ON)

cmake_dependent_option(EXT_SIMPLEXML_SHARED "Whether to build the simplexml extension as shared object" OFF "EXT_SIMPLEXML;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_SIMPLEXML)
  return()
endif()

if(NOT EXT_LIBXML)
  message(FATAL_ERROR "SimpleXML extension requires LIBXML extension, add -DEXT_LIBXML=ON")
endif()

if(EXT_SIMPLEXML_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "simplexml" ${_library_type})

add_library(ext_simplexml ${_library_type}
  simplexml.c
)

set_target_properties(ext_simplexml PROPERTIES PUBLIC_HEADER "php_simplexml.h;php_simplexml_exports.h")

target_link_libraries(ext_simplexml ext_libxml)
