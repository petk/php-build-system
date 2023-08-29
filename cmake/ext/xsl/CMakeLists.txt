include(CMakeDependentOption)

cmake_dependent_option(EXT_XSL "Whether to enable the XSL extension" OFF "EXT_DOM" OFF)

cmake_dependent_option(EXT_XSL_SHARED "Whether to build the XSL extension as shared object" OFF "EXT_XSL;NOT BUILD_SHARED_LIBS" OFF)

if(NOT EXT_XSL)
  return()
endif()

if(NOT EXT_LIBXML)
  message(FATAL_ERROR "XSL extension requires LIBXML extension, add -DEXT_LIBXML=ON")
endif()

if(NOT EXT_DOM)
  message(FATAL_ERROR "XSL extension requires DOM extension, add -Ddom=ON")
endif()

if(EXT_XSL_SHARED OR BUILD_SHARED_LIBS)
  set(_library_type "SHARED")
endif()

php_extension(NAME "xsl" ${_library_type})

add_library(ext_xsl ${_library_type}
  php_xsl.c
  xsltprocessor.c
)

target_link_libraries(ext_xsl PUBLIC ext_libxml)

find_package(LibXslt 1.1.0 REQUIRED)

target_link_libraries(ext_xsl PUBLIC "${LIBXSLT_LIBRARIES}")
target_include_directories(ext_xsl PUBLIC "${LIBXSLT_INCLUDE_DIR}")

if(LIBXSLT_EXSLT_LIBRARIES OR LIBXSLT_EXSLT_INCLUDE_DIR)
  target_link_libraries(ext_xsl PUBLIC "${LIBXSLT_EXSLT_LIBRARIES}")
  target_include_directories(ext_xsl PUBLIC "${LIBXSLT_EXSLT_INCLUDE_DIR}")
  set(HAVE_XSL_EXSLT 1 CACHE INTERNAL "Whether the libexslt library is available")
endif()
