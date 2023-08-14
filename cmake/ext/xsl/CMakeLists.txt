include(CMakeDependentOption)

cmake_dependent_option(xsl "Whether to enable the XSL extension" OFF "dom" OFF)

if(NOT xsl)
  return()
endif()

if(NOT libxml)
  message(FATAL_ERROR "XSL extension requires LIBXML extension, add -Dlibxml=ON")
endif()

if(NOT dom)
  message(FATAL_ERROR "XSL extension requires DOM extension, add -Ddom=ON")
endif()

string(TOLOWER ${xsl} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "xsl" ${extension_library_type})

add_library(ext_xsl ${extension_library_type}
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
