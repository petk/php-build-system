#[=============================================================================[
# The phar extension

Configure the `phar` extension.

This extension provides support for PHP archives (phar).

## PHP_EXT_PHAR

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_PHAR_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.
#]=============================================================================]

cmake_minimum_required(VERSION 4.2...4.3)

project(
  PHP_EXT_PHAR
  LANGUAGES C
)

include(CMakeDependentOption)
include(FeatureSummary)

option(PHP_EXT_PHAR "Enable the phar extension" ON)

add_feature_info(
  "ext/phar"
  PHP_EXT_PHAR
  "PHP archives support"
)

cmake_dependent_option(
  PHP_EXT_PHAR_SHARED
  "Build the phar extension as a shared library"
  OFF
  PHP_EXT_PHAR
  OFF
)

if(NOT PHP_EXT_PHAR)
  return()
endif()

################################################################################
# Add library.
################################################################################

if(PHP_EXT_PHAR_SHARED)
  add_library(php_ext_phar MODULE)
else()
  add_library(php_ext_phar OBJECT)
endif()

target_sources(
  php_ext_phar
  PRIVATE
    dirstream.c
    func_interceptors.c
    phar_object.c
    phar_object.stub.php
    phar_path_check.c
    phar.c
    stream.c
    tar.c
    util.c
    zip.c
)

target_compile_definitions(php_ext_phar PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

if(MSVC AND TODO)
  target_link_options(
    php_ext_phar
    PRIVATE
      # Silence irrelevant warning in release builds.
      $<$<NOT:$<CONFIG:Debug,DebugAssertions>>:LINKER:/IGNORE:4089>
  )
endif()

add_dependencies(php_ext_phar php_ext_hash php_ext_spl)

################################################################################
# Generate lexer files.
################################################################################

include(cmake/GenerateGrammar.cmake)

################################################################################
# Configure man documentation.
################################################################################

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Windows")
  configure_file(phar.1.in phar.1 @ONLY)
  configure_file(phar.phar.1.in phar.phar.1 @ONLY)

  install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/phar.1
    RENAME ${PHP_PROGRAM_PREFIX}phar${PHP_PROGRAM_SUFFIX}.1
    DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
    COMPONENT php-doc
  )

  install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/phar.phar.1
    RENAME ${PHP_PROGRAM_PREFIX}phar${PHP_PROGRAM_SUFFIX}.phar.1
    DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
    COMPONENT php-doc
  )
endif()

################################################################################
# The phar command-line script.
################################################################################

if(NOT TARGET PHP::sapi::cli)
  return()
endif()

if(NOT CMAKE_CROSSCOMPILING)
  set(php_executable "$<TARGET_FILE:PHP::sapi::cli>")
elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
  set(php_executable "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:PHP::sapi::cli>")
else()
  return()
endif()

set(phar_shared_options "")
if(PHP_EXT_PHAR_SHARED)
  set(
    phar_shared_options
      -d extension_dir=${PHP_BINARY_DIR}/modules/$<CONFIG>
      -d extension=phar
  )
endif()

cmake_path(
  RELATIVE_PATH
  CMAKE_CURRENT_BINARY_DIR
  BASE_DIRECTORY ${CMAKE_BINARY_DIR}
  OUTPUT_VARIABLE relative_dir
)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  COMMAND
    ${php_executable}
      -n
      ${phar_shared_options}
      -d open_basedir=
      -d output_buffering=0
      -d memory_limit=-1
      -d phar.readonly=0
      ${CMAKE_CURRENT_SOURCE_DIR}/build_precommand.php
      > ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  COMMENT "[ext/phar] Generating ${relative_dir}/phar.php"
  VERBATIM
)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
  COMMAND
    ${php_executable}
      -n
      ${phar_shared_options}
      -d open_basedir=
      -d output_buffering=0
      -d memory_limit=-1
      -d phar.readonly=0
      ${CMAKE_CURRENT_BINARY_DIR}/phar.php
        pack
        -f ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
        -a pharcommand
        -c auto
        -p 0
        -s ${CMAKE_CURRENT_SOURCE_DIR}/phar/phar.php
        -h sha1
        -b "$<TARGET_FILE:PHP::sapi::cli>"
        ${CMAKE_CURRENT_SOURCE_DIR}/phar
  DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  COMMENT "[ext/phar] Generating ${relative_dir}/phar.phar"
  VERBATIM
)

# Set phar.phar permissions.
file(
  CONFIGURE
  OUTPUT CMakeFiles/PharPermissions.cmake
  CONTENT [[
    file(
      CHMOD
      "@CMAKE_CURRENT_BINARY_DIR@/phar.phar"
      FILE_PERMISSIONS
        OWNER_READ
        OWNER_WRITE
        OWNER_EXECUTE
        GROUP_READ
        GROUP_WRITE
        GROUP_EXECUTE
        WORLD_READ
        WORLD_EXECUTE
    )
  ]]
  @ONLY
)

add_custom_command(
  OUTPUT php_ext_phar_generated_phar
  COMMAND ${CMAKE_COMMAND} -P CMakeFiles/PharPermissions.cmake
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
  COMMENT "[ext/phar] Generating ${relative_dir}/phar"
)

file(
  GLOB_RECURSE
  dependent_files
  ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.inc
  ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.php
)

add_custom_target(
  php_ext_phar_generate_file
  ALL
  DEPENDS
    PHP::sapi::cli
    php_ext_phar
    ${dependent_files}
    php_ext_phar_generated_phar
)
set_property(SOURCE php_ext_phar_generated_phar PROPERTY SYMBOLIC TRUE)

# Install phar.phar file to destination. Here a duplicate phar.phar generation
# step is used to generate it to a destination directory because of the install
# prefix used in shebang (when using 'cmake --install --prefix ...').
install(DIRECTORY DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT php)
string(CONFIGURE [[
  execute_process(
    COMMAND
      "@php_executable@"
        -n
        @phar_shared_options@
        -d open_basedir=
        -d output_buffering=0
        -d memory_limit=-1
        -d phar.readonly=0
        "@CMAKE_CURRENT_BINARY_DIR@/phar.php"
          pack
          -f "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/phar.phar"
          -a pharcommand
          -c auto
          -p 0
          -s "@CMAKE_CURRENT_SOURCE_DIR@/phar/phar.php"
          -h sha1
          -b "$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_BINDIR@,${CMAKE_INSTALL_PREFIX}>/$<TARGET_FILE_NAME:PHP::sapi::cli>"
          "@CMAKE_CURRENT_SOURCE_DIR@/phar"
  )

  file(
    CHMOD
    "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/phar.phar"
    FILE_PERMISSIONS
      OWNER_READ
      OWNER_WRITE
      OWNER_EXECUTE
      GROUP_READ
      GROUP_EXECUTE
      WORLD_READ
      WORLD_EXECUTE
  )

  file(
    COPY_FILE
    "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/phar.phar"
    $ENV{DESTDIR}$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_BINDIR@,${CMAKE_INSTALL_PREFIX}>/@PHP_PROGRAM_PREFIX@phar@PHP_PROGRAM_SUFFIX@.phar
  )

  file(
    CREATE_LINK
    @PHP_PROGRAM_PREFIX@phar@PHP_PROGRAM_SUFFIX@.phar
    $ENV{DESTDIR}$<PATH:ABSOLUTE_PATH,NORMALIZE,@CMAKE_INSTALL_BINDIR@,${CMAKE_INSTALL_PREFIX}>/@PHP_PROGRAM_PREFIX@phar@PHP_PROGRAM_SUFFIX@
    SYMBOLIC
  )
]] code @ONLY)
install(CODE "${code}" COMPONENT php)
