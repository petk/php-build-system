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

if(NOT CMAKE_CROSSCOMPILING)
  set(PHP_EXECUTABLE "$<TARGET_FILE:php_cli>")
elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
  set(PHP_EXECUTABLE "${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:php_cli>")
endif()

# Generate phar.php.
if(PHP_EXECUTABLE)
  file(
    GLOB_RECURSE
    dependent_files
    ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.inc
    ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.php
  )

  if(EXT_PHAR_SHARED OR BUILD_SHARED_LIBS)
    set(
      phar_shared_options
        -d extension_dir=${PHP_BINARY_DIR}/modules
        -d extension=phar
    )
  endif()

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.php
    COMMAND
      ${PHP_EXECUTABLE}
        -n
        ${phar_shared_options}
        -d open_basedir=
        -d output_buffering=0
        -d memory_limit=-1
        -d phar.readonly=0
        ${CMAKE_CURRENT_SOURCE_DIR}/build_precommand.php
        > ${CMAKE_CURRENT_BINARY_DIR}/phar.php
    COMMENT "[ext/phar] Generating phar.php"
    VERBATIM
  )

  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
    COMMAND
      ${PHP_EXECUTABLE}
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
          -b "$<TARGET_FILE:php_cli>"
          ${CMAKE_CURRENT_SOURCE_DIR}/phar
    DEPENDS
      ${CMAKE_CURRENT_BINARY_DIR}/phar.php
    COMMENT "[ext/phar] Generating phar.phar"
    VERBATIM
  )

  file(
    GENERATE
    OUTPUT CMakeFiles/GeneratePhar.cmake
    CONTENT [[
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

  add_custom_command(
    OUTPUT php_phar_generated_phar
    COMMAND
      ${CMAKE_COMMAND}
      -D CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
      -P CMakeFiles/GeneratePhar.cmake
    DEPENDS
      ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
    COMMENT "[ext/phar] Generating phar"
  )

  add_custom_target(
    php_phar_generate_file
    ALL
    DEPENDS
      php_cli
      php_phar
      ${dependent_files}
      php_phar_generated_phar
  )
  set_property(SOURCE php_phar_generated_phar PROPERTY SYMBOLIC TRUE)

  # Install phar.phar file to destination. Here a duplicate phar.phar generation
  # step is used to generate it to a destination directory because of the
  # install prefix used in shebang (when using 'cmake --install --prefix ...').
  install(CODE "
    execute_process(
      COMMAND
        ${PHP_EXECUTABLE}
          -n
          ${phar_shared_options}
          -d open_basedir=
          -d output_buffering=0
          -d memory_limit=-1
          -d phar.readonly=0
          ${CMAKE_CURRENT_BINARY_DIR}/phar.php
            pack
            -f \${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/phar.phar
            -a pharcommand
            -c auto
            -p 0
            -s ${CMAKE_CURRENT_SOURCE_DIR}/phar/phar.php
            -h sha1
            -b \${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/$<TARGET_FILE_NAME:php_cli>
            ${CMAKE_CURRENT_SOURCE_DIR}/phar
    )

    file(
      CHMOD
      \${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/phar.phar
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
  ")
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
