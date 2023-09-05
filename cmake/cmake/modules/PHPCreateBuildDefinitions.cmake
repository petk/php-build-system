#[=============================================================================[
Create build definitions header file main/build-defs.h.
]=============================================================================]#

function(php_create_build_definitions)
  message(STATUS "Creating main/build-defs.h")

  set(HAVE_BUILD_DEFS_H 1 CACHE INTERNAL "Define to 1 if you have the build-defs.h header file.")

  # TODO: Set configure command string.
  set(CONFIGURE_COMMAND "cmake" CACHE INTERNAL "Configuration command used for building PHP.")

  set(INCLUDE_PATH ".:" CACHE INTERNAL "The include_path directive.")

  # Set the PHP_EXTENSION_DIR based on the layout used.
  if(NOT PHP_EXTENSION_DIR)
    file(READ "${CMAKE_SOURCE_DIR}/Zend/zend_modules.h" content)
    string(REGEX MATCH "#define ZEND_MODULE_API_NO ([0-9]*)" _ "${content}")
    set(zend_module_api_no ${CMAKE_MATCH_1})

    set(php_extension_dir "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/php")

    if(PHP_LAYOUT STREQUAL "GNU")
      set(php_extension_dir "${php_extension_dir}/${zend_module_api_no}")

      if(PHP_ZTS)
        set(php_extension_dir "${php_extension_dir}-zts")
      endif()

      if(PHP_DEBUG)
        set(php_extension_dir "${php_extension_dir}-debug")
      endif()
    else()
      set(php_extension_dir "${php_extension_dir}/extensions")

      if(PHP_DEBUG)
        set(php_extension_dir "${php_extension_dir}/debug")
      else()
        set(php_extension_dir "${php_extension_dir}/no-debug")
      endif()

      if(PHP_ZTS)
        set(php_extension_dir "${php_extension_dir}-zts")
      else()
        set(php_extension_dir "${php_extension_dir}-non-zts")
      endif()

      set(php_extension_dir "${php_extension_dir}-${zend_module_api_no}")
    endif()

    set(PHP_EXTENSION_DIR "${php_extension_dir}" CACHE STRING "PHP extensions directory" FORCE)

    set(EXPANDED_EXTENSION_DIR "${PHP_EXTENSION_DIR}" CACHE INTERNAL "" FORCE)
  endif()

  # Set shared library object extension.
  string(REPLACE "." "" SHLIB_DL_SUFFIX_NAME ${CMAKE_SHARED_LIBRARY_SUFFIX})
  set(SHLIB_DL_SUFFIX_NAME ${SHLIB_DL_SUFFIX_NAME} CACHE INTERNAL "The suffix for shared libraries.")

  configure_file(main/build-defs.h.in main/build-defs.h @ONLY)
endfunction()

php_create_build_definitions()
