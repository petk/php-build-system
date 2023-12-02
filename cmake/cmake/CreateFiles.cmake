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

# Create main/build-defs.h file.
block(SCOPE_FOR VARIABLES)
  # TODO: Set configure command string.
  set(CONFIGURE_COMMAND "cmake")

  # TODO: Set ODBC_CFLAGS, ODBC_LFLAGS, ODBC_LIBS, ODBC_TYPE.
  set(ODBC_CFLAGS "")
  set(ODBC_LFLAGS "")
  set(ODBC_LIBS "")
  set(ODBC_TYPE "")

  # Set the 'include_path' INI directive.
  set(INCLUDE_PATH ".:${EXPANDED_PEAR_INSTALLDIR}")

  set(EXPANDED_EXTENSION_DIR "${PHP_EXTENSION_DIR}")
  set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}")
  set(EXPANDED_BINDIR "${CMAKE_INSTALL_FULL_BINDIR}")
  set(EXPANDED_SBINDIR "${CMAKE_INSTALL_FULL_SBINDIR}")
  set(EXPANDED_MANDIR "${CMAKE_INSTALL_FULL_MANDIR}")
  set(EXPANDED_LIBDIR "${CMAKE_INSTALL_FULL_LIBDIR}")
  set(EXPANDED_DATADIR "${CMAKE_INSTALL_FULL_DATADIR}")
  set(EXPANDED_SYSCONFDIR "${CMAKE_INSTALL_FULL_SYSCONFDIR}")
  set(EXPANDED_LOCALSTATEDIR "${CMAKE_INSTALL_FULL_LOCALSTATEDIR}")
  set(prefix "${CMAKE_INSTALL_PREFIX}")

  # Set shared library object extension.
  string(REPLACE "." "" SHLIB_DL_SUFFIX_NAME ${CMAKE_SHARED_LIBRARY_SUFFIX})

  message(STATUS "Creating main/build-defs.h")
  configure_file(
    ${PROJECT_SOURCE_DIR}/main/build-defs.h.in
    ${PROJECT_BINARY_DIR}/main/build-defs.h
    @ONLY
  )

  set(
    HAVE_BUILD_DEFS_H 1
    CACHE INTERNAL "Whether build-defs.h header file is present."
  )
endblock()

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
  ${PROJECT_SOURCE_DIR}/main/internal_functions.c.in
  ${PROJECT_BINARY_DIR}/main/internal_functions.c
)

message(STATUS "Creating main/internal_functions_cli.c")
configure_file(
  ${PROJECT_SOURCE_DIR}/main/internal_functions.c.in
  ${PROJECT_BINARY_DIR}/main/internal_functions_cli.c
)

message(STATUS "Creating main/php_config.h")
configure_file(main/php_config.cmake.h.in main/php_config.h @ONLY)

message(STATUS "Creating main/php_version.h")
configure_file(main/php_version.h.in main/php_version.h @ONLY)

# Man documentation.
message(STATUS "Creating scripts/man1/php-config.1")
configure_file(
  ${PROJECT_SOURCE_DIR}/scripts/man1/php-config.1.in
  ${PROJECT_BINARY_DIR}/scripts/man1/php-config.1
  @ONLY
)

message(STATUS "Creating scripts/man1/phpize.1")
configure_file(
  ${PROJECT_SOURCE_DIR}/scripts/man1/phpize.1.in
  ${PROJECT_BINARY_DIR}/scripts/man1/phpize.1
  @ONLY
)

# The php-config script.
set(EXPANDED_PHP_CONFIG_FILE_SCAN_DIR "${PHP_CONFIG_FILE_SCAN_DIR}")
message(STATUS "Creating scripts/php-config")
configure_file(
  ${PROJECT_SOURCE_DIR}/scripts/php-config.in
  ${PROJECT_BINARY_DIR}/scripts/php-config
  @ONLY
)
