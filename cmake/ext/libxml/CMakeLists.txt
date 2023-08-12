option(libxml "Whether to enable the libxml extension" ON)

if(libxml)
  # This extension can be build only as STATIC.
  php_extension(NAME "libxml" STATIC)

  add_library(ext_libxml STATIC
    libxml.c
  )

  target_compile_definitions(ext_libxml PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

  set_target_properties(ext_libxml PROPERTIES PUBLIC_HEADER "php_libxml.h")

  find_package(LibXml2 2.9.0 REQUIRED GLOBAL)

  target_link_libraries(ext_libxml PUBLIC "${LIBXML2_LIBRARIES}")
  target_include_directories(ext_libxml PUBLIC "${LIBXML2_INCLUDE_DIRS}")
endif()
