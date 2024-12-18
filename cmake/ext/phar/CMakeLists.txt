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

project(
  PhpExtensionPhar
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
  "PHP_EXT_PHAR;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT PHP_EXT_PHAR)
  return()
endif()

################################################################################
# Add library.
################################################################################

if(PHP_EXT_PHAR_SHARED)
  add_library(php_ext_phar SHARED)
else()
  add_library(php_ext_phar)
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
  PUBLIC
    FILE_SET HEADERS
      FILES
        php_phar.h
)

target_compile_definitions(php_ext_phar PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

target_link_options(
  php_ext_phar
  PRIVATE
    # Silence irrelevant-to-us warning in release builds.
    $<$<AND:$<NOT:$<CONFIG:Debug,DebugAssertions>>,$<C_COMPILER_ID:MSVC>>:LINKER:/IGNORE:4089>
)

add_dependencies(php_ext_phar php_ext_hash php_ext_spl)

if(RE2C_FOUND)
  re2c_target(
    php_ext_phar_path_check
    phar_path_check.re
    ${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c
    OPTIONS -b
  )
endif()

################################################################################
# Man documentation.
################################################################################

configure_file(phar.1.in phar.1 @ONLY)
configure_file(phar.phar.1.in phar.phar.1 @ONLY)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/phar.1
  RENAME ${PHP_PROGRAM_PREFIX}phar${PHP_PROGRAM_SUFFIX}.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/phar.phar.1
  RENAME ${PHP_PROGRAM_PREFIX}phar${PHP_PROGRAM_SUFFIX}.phar.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

################################################################################
# The phar command-line script.
################################################################################

if(NOT TARGET PHP::SAPI::cli)
  return()
endif()

if(NOT CMAKE_CROSSCOMPILING)
  set(PHP_EXECUTABLE "$<TARGET_FILE:PHP::SAPI::cli>")
elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
  set(PHP_EXECUTABLE "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:PHP::SAPI::cli>")
else()
  return()
endif()

set(pharSharedOptions "")
if(PHP_EXT_PHAR_SHARED OR BUILD_SHARED_LIBS)
  set(
    pharSharedOptions
      -d extension_dir=${PHP_BINARY_DIR}/modules
      -d extension=phar
  )
endif()

cmake_path(
  RELATIVE_PATH
  CMAKE_CURRENT_BINARY_DIR
  BASE_DIRECTORY ${CMAKE_BINARY_DIR}
  OUTPUT_VARIABLE relativeDir
)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  COMMAND
    ${PHP_EXECUTABLE}
      -n
      ${pharSharedOptions}
      -d open_basedir=
      -d output_buffering=0
      -d memory_limit=-1
      -d phar.readonly=0
      ${CMAKE_CURRENT_SOURCE_DIR}/build_precommand.php
      > ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  COMMENT "[ext/phar] Generating ${relativeDir}/phar.php"
  VERBATIM
)

add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
  COMMAND
    ${PHP_EXECUTABLE}
      -n
      ${pharSharedOptions}
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
        -b "$<TARGET_FILE:PHP::SAPI::cli>"
        ${CMAKE_CURRENT_SOURCE_DIR}/phar
  DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  COMMENT "[ext/phar] Generating ${relativeDir}/phar.phar"
  VERBATIM
)

# Set phar.phar permissions.
file(
  GENERATE
  OUTPUT CMakeFiles/PharPermissions.cmake
  CONTENT "
    file(
      CHMOD
      ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
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
  "
)

add_custom_command(
  OUTPUT php_ext_phar_generated_phar
  COMMAND
    ${CMAKE_COMMAND} -P CMakeFiles/PharPermissions.cmake
  DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
  COMMENT "[ext/phar] Generating ${relativeDir}/phar"
)

file(
  GLOB_RECURSE
  dependentFiles
  ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.inc
  ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.php
)

add_custom_target(
  php_ext_phar_generate_file
  ALL
  DEPENDS
    PHP::SAPI::cli
    php_ext_phar
    ${dependentFiles}
    php_ext_phar_generated_phar
)
set_property(SOURCE php_ext_phar_generated_phar PROPERTY SYMBOLIC TRUE)

# Install phar.phar file to destination. Here a duplicate phar.phar generation
# step is used to generate it to a destination directory because of the install
# prefix used in shebang (when using 'cmake --install --prefix ...').
install(CODE "
  execute_process(
    COMMAND
      ${PHP_EXECUTABLE}
        -n
        ${pharSharedOptions}
        -d open_basedir=
        -d output_buffering=0
        -d memory_limit=-1
        -d phar.readonly=0
        ${CMAKE_CURRENT_BINARY_DIR}/phar.php
          pack
          -f ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/phar.phar
          -a pharcommand
          -c auto
          -p 0
          -s ${CMAKE_CURRENT_SOURCE_DIR}/phar/phar.php
          -h sha1
          -b $<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_BINDIR},\${CMAKE_INSTALL_PREFIX}>/$<TARGET_FILE_NAME:PHP::SAPI::cli>
          ${CMAKE_CURRENT_SOURCE_DIR}/phar
  )

  file(
    CHMOD
    ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/phar.phar
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
    ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/phar.phar
    \$ENV{DESTDIR}$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_BINDIR},\${CMAKE_INSTALL_PREFIX}>/${PHP_PROGRAM_PREFIX}phar${PHP_PROGRAM_SUFFIX}.phar
  )

  file(
    CREATE_LINK
    ${PHP_PROGRAM_PREFIX}phar${PHP_PROGRAM_SUFFIX}.phar
    \$ENV{DESTDIR}$<PATH:ABSOLUTE_PATH,NORMALIZE,${CMAKE_INSTALL_BINDIR},\${CMAKE_INSTALL_PREFIX}>/${PHP_PROGRAM_PREFIX}phar${PHP_PROGRAM_SUFFIX}
    SYMBOLIC
  )
")
