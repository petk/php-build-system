#[=============================================================================[
Create build definitions header file main/build-defs.h.
]=============================================================================]#

function(php_create_build_definitions)
  message(STATUS "Creating main/build-defs.h")

  set(HAVE_BUILD_DEFS_H 1 CACHE INTERNAL "Define to 1 if you have the build-defs.h header file.")

  set(INCLUDE_PATH ".:" CACHE INTERNAL "The include_path directive.")

  # Set the PHP_EXTENSION_DIR based on the layout used.
  if(NOT PHP_EXTENSION_DIR)
    file(READ "${CMAKE_SOURCE_DIR}/Zend/zend_modules.h" content)
    string(REGEX MATCH "#define ZEND_MODULE_API_NO ([0-9]*)" _ "${content}")
    set(_zend_module_api_no ${CMAKE_MATCH_1})

    set(PHP_EXTENSION_DIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/php")

    if(PHP_LAYOUT STREQUAL "GNU")
      set(PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}/${_zend_module_api_no}")

      if(ZTS)
        set(PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}-zts")
      endif()

      if(DEBUG)
        set(PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}-debug")
      endif()
    else()
      set(PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}/extensions")

      if(DEBUG)
        set(PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}/debug")
      else()
        set(PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}/no-debug")
      endif()

      if(ZTS)
        set(PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}-zts")
      else()
        set(PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}-non-zts")
      endif()

      set(PHP_EXTENSION_DIR "${PHP_EXTENSION_DIR}-${_zend_module_api_no}")
    endif()

    set(EXPANDED_EXTENSION_DIR "${PHP_EXTENSION_DIR}" CACHE INTERNAL "")
  endif()

  configure_file(main/build-defs.h.in main/build-defs.h @ONLY)
endfunction()

php_create_build_definitions()