include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PHAR "Enable the phar extension" ON)

add_feature_info(
  "ext/phar"
  EXT_PHAR
  "PHP archives (phar) support"
)

cmake_dependent_option(
  EXT_PHAR_SHARED
  "Build the phar extension as a shared library"
  OFF
  "EXT_PHAR;NOT BUILD_SHARED_LIBS"
  OFF
)

if(NOT EXT_PHAR)
  return()
endif()

################################################################################
# Add library.
################################################################################

if(EXT_PHAR_SHARED)
  add_library(php_phar SHARED)
else()
  add_library(php_phar)
endif()

target_sources(
  php_phar
  PRIVATE
    dirstream.c
    func_interceptors.c
    phar_object.c
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

target_compile_definitions(php_phar PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

target_link_options(
  php_phar
  PRIVATE
    # Silence irrelevant-to-us warning in release builds.
    $<$<AND:$<NOT:$<CONFIG:Debug,DebugAssertions>>,$<C_COMPILER_ID:MSVC>>:LINKER:/IGNORE:4089>
)

add_dependencies(php_phar php_hash php_spl)

if(RE2C_FOUND)
  re2c_target(
    php_phar_path_check
    phar_path_check.re
    ${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c
    OPTIONS -b
  )
endif()

################################################################################
# Generate files.
################################################################################

# When cross-compiling php cli target executable cannot be executed.
if(NOT CMAKE_CROSSCOMPILING)
  block()
    # Create CMake script that generates phar.phar file.
    file(
      GENERATE
      OUTPUT CMakeFiles/GeneratePhar.cmake
      CONTENT [[
        # Generate phar.php.
        if(EXT_PHAR_SHARED OR BUILD_SHARED_LIBS)
          set(
            phar_shared_options
              -d extension_dir=${PHP_BINARY_DIR}/modules
              -d extension=phar
          )
        endif()

        execute_process(
          COMMAND
            ${PHP_EXECUTABLE}
              -n
              ${phar_shared_options}
              -d open_basedir=
              -d output_buffering=0
              -d memory_limit=-1
              -d phar.readonly=0
              ${CURRENT_SOURCE_DIR}/build_precommand.php
          OUTPUT_FILE ${CURRENT_BINARY_DIR}/phar.php
          OUTPUT_QUIET
        )

        # Generate phar.phar.
        execute_process(
          COMMAND
            ${PHP_EXECUTABLE}
              -n
              ${phar_shared_options}
              -d open_basedir=
              -d output_buffering=0
              -d memory_limit=-1
              -d phar.readonly=0
              ${CURRENT_BINARY_DIR}/phar.php
                pack
                -f ${CURRENT_BINARY_DIR}/phar.phar
                -a pharcommand
                -c auto
                -p 0
                -s ${CURRENT_SOURCE_DIR}/phar/phar.php
                -h sha1
                -b ${INSTALL_FULL_BINDIR}/${php_cli_filename}
                ${CURRENT_SOURCE_DIR}/phar
        )

        # Set phar.phar permissions.
        file(
          CHMOD
          ${CURRENT_BINARY_DIR}/phar.phar
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
    )

    file(
      GLOB_RECURSE
      dependent_files
      ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.inc
      ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.php
    )

    add_custom_command(
      OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
      COMMAND
        ${CMAKE_COMMAND}
        -D EXT_PHAR_SHARED=${EXT_PHAR_SHARED}
        -D BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -D PHP_BINARY_DIR=${PHP_BINARY_DIR}
        -D PHP_EXECUTABLE=$<TARGET_FILE:php_cli>
        -D php_cli_filename=$<TARGET_FILE_NAME:php_cli>
        -D CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
        -D CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
        -D INSTALL_FULL_BINDIR=${CMAKE_INSTALL_FULL_BINDIR}
        -P CMakeFiles/GeneratePhar.cmake
      DEPENDS
        php_cli
        php_phar
        ${dependent_files}
      COMMENT "[ext/phar] Generating phar.phar"
    )

    # Create target which consumes the command via DEPENDS.
    add_custom_target(
      php_phar_generated_files
      ALL
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
      COMMENT "[ext/phar] Generating phar files"
    )
  endblock()
endif()

# Man documentation.
configure_file(phar.1.in phar.1 @ONLY)
configure_file(phar.phar.1.in phar.phar.1 @ONLY)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/phar.1
    ${CMAKE_CURRENT_BINARY_DIR}/phar.phar.1
  DESTINATION ${CMAKE_INSTALL_MANDIR}/man1
)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
  DESTINATION ${CMAKE_INSTALL_BINDIR}
)
