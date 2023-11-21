#[=============================================================================[
Creates files from templates.
]=============================================================================]#

################################################################################
# Set replacement values.
################################################################################
if(PHP_CONFIG_FILE_PATH STREQUAL "")
  if(PHP_LAYOUT STREQUAL "GNU")
    set(EXPANDED_PHP_CONFIG_FILE_PATH "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
  else()
    set(EXPANDED_PHP_CONFIG_FILE_PATH "${CMAKE_INSTALL_FULL_LIBDIR}")
  endif()
else()
  set(EXPANDED_PHP_CONFIG_FILE_PATH "${PHP_CONFIG_FILE_PATH}")
endif()

if(PHP_PEAR)
  if(PHP_PEAR_DIR STREQUAL "")
    if(PHP_LAYOUT STREQUAL "GNU")
      set(EXPANDED_PEAR_INSTALLDIR "${CMAKE_INSTALL_FULL_DATADIR}/pear")
    else()
      set(EXPANDED_PEAR_INSTALLDIR "${CMAKE_INSTALL_FULL_LIBDIR}/php")
    endif()
  else()
    set(EXPANDED_PEAR_INSTALLDIR "${PHP_PEAR_DIR}")
  endif()
endif()

# Create main/build-defs.h file.
function(_php_create_build_definitions)
  # TODO: Set configure command string.
  set(CONFIGURE_COMMAND "cmake")

  # Set the 'include_path' INI directive.
  set(INCLUDE_PATH ".:${EXPANDED_PEAR_INSTALLDIR}")

  # Set the PHP_EXTENSION_DIR based on the layout used.
  if(NOT PHP_EXTENSION_DIR)
    file(READ "${CMAKE_SOURCE_DIR}/Zend/zend_modules.h" content)
    string(REGEX MATCH "#define ZEND_MODULE_API_NO ([0-9]*)" _ "${content}")
    set(zend_module_api_no ${CMAKE_MATCH_1})

    set(php_extension_dir "${CMAKE_INSTALL_FULL_LIBDIR}/php")

    if(PHP_LAYOUT STREQUAL "GNU")
      set(php_extension_dir "${php_extension_dir}/${zend_module_api_no}")

      if(PHP_THREAD_SAFETY)
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

      if(PHP_THREAD_SAFETY)
        set(php_extension_dir "${php_extension_dir}-zts")
      else()
        set(php_extension_dir "${php_extension_dir}-non-zts")
      endif()

      set(php_extension_dir "${php_extension_dir}-${zend_module_api_no}")
    endif()

    set_property(CACHE PHP_EXTENSION_DIR PROPERTY VALUE "${php_extension_dir}")
  endif()

  set(EXPANDED_EXTENSION_DIR "${PHP_EXTENSION_DIR}")

  # Set shared library object extension.
  string(REPLACE "." "" SHLIB_DL_SUFFIX_NAME ${CMAKE_SHARED_LIBRARY_SUFFIX})
  set(SHLIB_DL_SUFFIX_NAME ${SHLIB_DL_SUFFIX_NAME} CACHE INTERNAL "The suffix for shared libraries.")

  set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}")

  message(STATUS "Creating main/build-defs.h")
  configure_file(
    ${CMAKE_SOURCE_DIR}/main/build-defs.h.in
    ${CMAKE_BINARY_DIR}/main/build-defs.h
    @ONLY
  )

  set(
    HAVE_BUILD_DEFS_H 1
    CACHE INTERNAL "Whether build-defs.h header file is present."
  )
endfunction()

_php_create_build_definitions()

# Create main/internal_functions* files.
set(EXT_INCLUDE_CODE "")
set(EXT_MODULE_PTRS "")

# Add artefacts of static enabled PHP extensions to symbol definitions.
get_cmake_property(php_extensions PHP_EXTENSIONS)
foreach(extension IN LISTS php_extensions)
  # Skip if extension is shared.
  get_target_property(extension_type php_${extension} TYPE)
  if(extension_type STREQUAL "SHARED_LIBRARY")
    continue()
  endif()

  file(GLOB_RECURSE extension_headers
    "${PROJECT_SOURCE_DIR}/ext/${extension}/*.h"
  )

  foreach(extension_header IN LISTS extension_headers)
    file(READ "${extension_header}" file_content)
    string(FIND "${file_content}" "phpext_" pattern_index)

    if(NOT pattern_index EQUAL -1)
      cmake_path(GET extension_header FILENAME file_name)
      set(EXT_INCLUDE_CODE "${EXT_INCLUDE_CODE}\n#include \"ext/${extension}/${file_name}\"")
    endif()
  endforeach()

  set(EXT_MODULE_PTRS "${EXT_MODULE_PTRS}\n\tphpext_${extension}_ptr,")
endforeach()

message(STATUS "Creating main/internal_functions.c")
configure_file(
  ${CMAKE_SOURCE_DIR}/main/internal_functions.c.in
  ${CMAKE_BINARY_DIR}/main/internal_functions.c
)

message(STATUS "Creating main/internal_functions_cli.c")
configure_file(
  ${CMAKE_SOURCE_DIR}/main/internal_functions.c.in
  ${CMAKE_BINARY_DIR}/main/internal_functions_cli.c
)

message(STATUS "Creating main/php_config.h")
configure_file(main/php_config.cmake.h.in main/php_config.h @ONLY)

message(STATUS "Creating main/php_version.h")
configure_file(main/php_version.h.in main/php_version.h @ONLY)

# Man documentation.
message(STATUS "Creating scripts/man1/php-config.1")
configure_file(
  ${CMAKE_SOURCE_DIR}/scripts/man1/php-config.1.in
  ${CMAKE_BINARY_DIR}/scripts/man1/php-config.1
  @ONLY
)

message(STATUS "Creating scripts/man1/phpize.1")
configure_file(
  ${CMAKE_SOURCE_DIR}/scripts/man1/phpize.1.in
  ${CMAKE_BINARY_DIR}/scripts/man1/phpize.1
  @ONLY
)

# The php-config script.
set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}")
message(STATUS "Creating scripts/php-config")
configure_file(
  ${CMAKE_SOURCE_DIR}/scripts/php-config.in
  ${CMAKE_BINARY_DIR}/scripts/php-config
  @ONLY
)
