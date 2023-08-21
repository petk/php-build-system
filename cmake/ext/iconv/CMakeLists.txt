option(iconv "Whether to enable the iconv extension" ON)

if(NOT iconv)
  return()
endif()

string(TOLOWER ${iconv} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME "iconv" ${extension_library_type})

add_library(ext_iconv ${extension_library_type}
  iconv.c
)

target_compile_definitions(ext_iconv PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

file(GLOB ICONV_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
set_target_properties(ext_iconv PROPERTIES PUBLIC_HEADER "${ICONV_HEADER_FILES}")

find_package(ICONV REQUIRED)

if(${ICONV_LIBRARIES})
  target_link_libraries(ext_iconv PRIVATE ${ICONV_LIBRARIES})
endif()

if(${ICONV_INCLUDE_DIRS})
  target_include_directories(ext_iconv PRIVATE ${ICONV_INCLUDE_DIRS})
endif()
