#[=============================================================================[
# The phar extension

This extension provides support for PHP archives (phar).

## Configuration options

### PHP_EXT_PHAR

* Default: `ON`
* Values: `ON|OFF|shared`

Enables the extension.
#]=============================================================================]

cmake_minimum_required(VERSION 4.3...4.4)

project(
  PHP_EXT_PHAR
  SPDX_LICENSE "PHP-3.01 AND BSD-3-Clause AND BSD-2-Clause"
  LANGUAGES C
)

include(FeatureSummary)

option(PHP_EXT_PHAR "Enable the phar extension" ON)

add_feature_info(
  "ext/phar"
  PHP_EXT_PHAR
  "PHP archives support"
)

if(NOT PHP_EXT_PHAR)
  return()
endif()

find_package(PHP REQUIRED)

include(PHP/AddCommand)

include(PHP/Extension)
php_extension(phar)

################################################################################
# Add library.
################################################################################

if(PHP_EXT_PHAR STREQUAL "shared" OR PROJECT_IS_TOP_LEVEL)
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
    stub.h
    tar.c
    util.c
    zip.c
)

target_include_directories(php_ext_phar PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_compile_definitions(php_ext_phar PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE)

if(MSVC AND TODO)
  target_link_options(
    php_ext_phar
    PRIVATE
      # Silence irrelevant warning in release builds.
      $<$<NOT:$<CONFIG:Debug,PhpRelWithDebInfo>>:LINKER:/IGNORE:4089>
  )
endif()

set_property(
  TARGET php_ext_phar
  APPEND
  PROPERTY PHP_REQUIRED_EXTENSIONS hash spl
)

set_property(
  TARGET php_ext_phar
  APPEND
  PROPERTY PHP_RECOMMENDED_EXTENSIONS bz2 openssl zlib
)

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
    DESTINATION ${PHP_INSTALL_MANDIR}/man1
    COMPONENT php-doc
  )

  install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/phar.phar.1
    RENAME ${PHP_PROGRAM_PREFIX}phar${PHP_PROGRAM_SUFFIX}.phar.1
    DESTINATION ${PHP_INSTALL_MANDIR}/man1
    COMPONENT php-doc
  )
endif()

################################################################################
# Generate ext/phar/stub.h.
################################################################################

php_add_command(
  php_ext_phar_generate_stub_h
  EXCLUDE_FROM_ALL
  ARGS
    ${CMAKE_CURRENT_SOURCE_DIR}/makestub.php
  PHP_EXTENSIONS tokenizer
  OUTPUT
    ${CMAKE_CURRENT_SOURCE_DIR}/stub.h
  DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/makestub.php
    ${CMAKE_CURRENT_SOURCE_DIR}/shortarc.php
  COMMENT "[ext/phar] Regenerating stub.h"
)

################################################################################
# Configure tests.
################################################################################

if(PHP_TESTING)
  add_subdirectory(tests)
endif()

################################################################################
# The phar command-line script.
################################################################################

if(NOT TARGET PHP::Interpreter AND NOT TARGET PHP::sapi::cli)
  message(
    WARNING
    "PHP command-line interpreter is missing. The phar.phar command-line tool "
    "will not be generated."
  )
  return()
endif()

set(
  php_options
  -n
  -d open_basedir=
  -d output_buffering=0
  -d memory_limit=-1
  -d phar.readonly=0
)

cmake_path(
  RELATIVE_PATH
  CMAKE_CURRENT_BINARY_DIR
  BASE_DIRECTORY ${CMAKE_BINARY_DIR}
  OUTPUT_VARIABLE relative_dir
)

if(TARGET PHP::Interpreter)
  set(args "")
else()
  set(args "ONLY_SAPI_CLI")
endif()

php_add_command(
  php_ext_phar_generate_phar_php
  ARGS
    ${php_options}
    ${CMAKE_CURRENT_SOURCE_DIR}/build_precommand.php
    > ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  ${args}
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  DEPENDS
    php_ext_phar
    ${CMAKE_CURRENT_SOURCE_DIR}/build_precommand.php
    ${CMAKE_CURRENT_SOURCE_DIR}/phar/clicommand.inc
    ${CMAKE_CURRENT_SOURCE_DIR}/phar/directorygraphiterator.inc
    ${CMAKE_CURRENT_SOURCE_DIR}/phar/directorytreeiterator.inc
    ${CMAKE_CURRENT_SOURCE_DIR}/phar/invertedregexiterator.inc
    ${CMAKE_CURRENT_SOURCE_DIR}/phar/pharcommand.inc
  COMMENT "[ext/phar] Generating ${relative_dir}/phar.php"
)

if(PHP_BINARY_DIR)
  set(dir ${PHP_BINARY_DIR})
  set(shebang "$<TARGET_FILE:PHP::sapi::cli>")
else()
  set(dir ${CMAKE_CURRENT_BINARY_DIR})
  set(shebang "$<TARGET_FILE:PHP::Interpreter>")
endif()

get_target_property(type php_ext_phar TYPE)
if(type STREQUAL "MODULE_LIBRARY")
  list(
    APPEND
    php_options
    -d extension=${dir}/modules/$<CONFIG>/phar${CMAKE_SHARED_MODULE_SUFFIX}
  )
endif()

# The phar.inc is loaded in the phar/pharcommand.inc file based on the
# execution. However, it's unclear how to reproduce its usage from the build
# directory. Copying to build directory is here only to be synced with the
# upstream build system, but the *.inc retrieval is added for reproducible
# phar file generation. See https://github.com/php/php-src/issues/19997
file(
  GLOB
  phar_sources_relative
  LIST_DIRECTORIES FALSE
  RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.inc
)
if(NOT CMAKE_CURRENT_BINARY_DIR PATH_EQUAL CMAKE_CURRENT_SOURCE_DIR)
  file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/phar)

  foreach(file IN LISTS phar_sources_relative)
    file(
      COPY_FILE
      ${CMAKE_CURRENT_SOURCE_DIR}/${file}
      ${CMAKE_CURRENT_BINARY_DIR}/${file}
    )
  endforeach()
endif()

set(phar_sources_absolute "")
foreach(file IN LISTS phar_sources_relative)
  list(APPEND phar_sources_absolute "${CMAKE_CURRENT_BINARY_DIR}/${file}")
endforeach()

php_add_command(
  php_ext_phar_generate_phar_phar
  ARGS
    ${php_options}
    ${CMAKE_CURRENT_BINARY_DIR}/phar.php
      pack
      -f ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
      -a pharcommand
      -c auto
      -p 0
      -s ${CMAKE_CURRENT_SOURCE_DIR}/phar/phar.php
      -h sha1
      -b "${shebang}"
      -l 1
      ${phar_sources_relative}
  ${args}
  OPTIONAL_EXTENSIONS bz2 zlib
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
  DEPENDS
    php_ext_phar
    ${CMAKE_CURRENT_BINARY_DIR}/phar.php
    ${CMAKE_CURRENT_SOURCE_DIR}/phar/phar.php
    ${phar_sources_absolute}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  COMMENT "[ext/phar] Generating ${relative_dir}/phar.phar"
)

# Set phar.phar permissions.
file(
  CONFIGURE
  OUTPUT CMakeFiles/PharPermissions.cmake
  CONTENT [[
    if(EXISTS "@CMAKE_CURRENT_BINARY_DIR@/phar.phar")
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
    endif()
  ]]
  @ONLY
)

add_custom_target(
  php_ext_phar_permissions
  ALL
  COMMAND ${CMAKE_COMMAND} -P CMakeFiles/PharPermissions.cmake
  DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
    php_ext_phar
)

if(TARGET PHP::sapi::cli)
  add_dependencies(php_ext_phar_permissions PHP::sapi::cli)
endif()

if(TARGET PHP::Interpreter)
  set(php_target "PHP::Interpreter")
  set(php_executable "$<TARGET_FILE:${php_target}>")
elseif(NOT CMAKE_CROSSCOMPILING)
  set(php_target "PHP::sapi::cli")
  set(php_executable "$<TARGET_FILE:${php_target}>")
elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
  set(php_target "PHP::sapi::cli")
  set(php_executable "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:${php_target}>")
else()
  return()
endif()

# Install phar.phar file to destination. Here a duplicate phar.phar generation
# step is used to generate it to a destination directory because of the install
# prefix used in shebang (when using 'cmake --install --prefix ...').
install(DIRECTORY DESTINATION ${PHP_INSTALL_BINDIR} COMPONENT php)
string(CONFIGURE [[
  execute_process(
    COMMAND
      "@php_executable@"
        @php_options@
        "@CMAKE_CURRENT_BINARY_DIR@/phar.php"
          pack
          -f "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/@PHP_PROGRAM_PREFIX@phar@PHP_PROGRAM_SUFFIX@.phar"
          -a pharcommand
          -c auto
          -p 0
          -s "@CMAKE_CURRENT_SOURCE_DIR@/phar/phar.php"
          -h sha1
          -b "$<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_INSTALL_BINDIR@,${CMAKE_INSTALL_PREFIX}>/$<TARGET_FILE_NAME:@php_target@>"
          "@CMAKE_CURRENT_SOURCE_DIR@/phar"
  )

  file(
    CREATE_LINK
    @PHP_PROGRAM_PREFIX@phar@PHP_PROGRAM_SUFFIX@.phar
    "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/@PHP_PROGRAM_PREFIX@phar@PHP_PROGRAM_SUFFIX@"
    SYMBOLIC
  )

  file(
    INSTALL
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/@PHP_PROGRAM_PREFIX@phar@PHP_PROGRAM_SUFFIX@.phar"
      "@CMAKE_CURRENT_BINARY_DIR@/CMakeFiles/@PHP_PROGRAM_PREFIX@phar@PHP_PROGRAM_SUFFIX@"
    DESTINATION $<PATH:ABSOLUTE_PATH,NORMALIZE,@PHP_INSTALL_BINDIR@,${CMAKE_INSTALL_PREFIX}>
    FILE_PERMISSIONS
      OWNER_READ
      OWNER_WRITE
      OWNER_EXECUTE
      GROUP_READ
      GROUP_EXECUTE
      WORLD_READ
      WORLD_EXECUTE
  )
]] code @ONLY)
install(CODE "${code}" COMPONENT php)
