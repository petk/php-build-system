include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PHAR "Enable the phar extension" ON)

add_feature_info(
  "ext/phar"
  EXT_PHAR
  "PHP archives (phar) support."
)

cmake_dependent_option(
  EXT_PHAR_NATIVE_SSL
  "Link the phar extension against the OpenSSL library directly"
  OFF
  "EXT_PHAR"
  OFF
)

mark_as_advanced(EXT_PHAR_NATIVE_SSL)

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
      BASE_DIRS "${PHP_SOURCE_DIR}"
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

set_target_properties(
  php_phar
  PROPERTIES
    PHP_EXTENSION_DEPENDENCIES "php_hash;php_spl"
)

if(RE2C_FOUND)
  re2c_target(
    NAME php_phar_path_check
    INPUT ${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.re
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c
    OPTIONS --no-generation-date -b
  )
endif()

message(CHECK_START "Checking for phar OpenSSL support")

if(EXT_PHAR_NATIVE_SSL)
  find_package(OpenSSL ${PHP_OPENSSL_MIN_VERSION})
  set_package_properties(
    OpenSSL
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the OpenSSL support in the phar extension."
  )

  target_link_libraries(php_phar PRIVATE OpenSSL::SSL OpenSSL::Crypto)

  if(OpenSSL_FOUND)
    set(PHAR_HAVE_OPENSSL 1 CACHE INTERNAL "Whether phar has OpenSSL support")
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
elseif(EXT_OPENSSL AND NOT EXT_OPENSSL_SHARED AND NOT BUILD_SHARED_LIBS)
  message(CHECK_PASS "yes, OpenSSL support enabled")
  set(PHAR_HAVE_OPENSSL 1 CACHE INTERNAL "Whether phar has OpenSSL support")
else()
  message(CHECK_FAIL "no, the openssl extension is disabled or shared")
endif()

################################################################################
# Generate files.
################################################################################

block()
  # Create CMake script that generates phar.phar file.
  file(
    GENERATE
    OUTPUT CMakeFiles/GeneratePhar.cmake
    CONTENT [[
      # Generate phar.php.
      if(EXT_PHAR_SHARED)
        set(
          phar_shared_options
            -d extension_dir=${PHP_BINARY_DIR}/modules
            -d extension=phar
        )
      endif()

      execute_process(
        COMMAND
          ${PHP_BINARY_DIR}/sapi/cli/${php_cli_filename}
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
          ${PHP_BINARY_DIR}/sapi/cli/${php_cli_filename}
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

  get_target_property(php_cli_basename php_cli OUTPUT_NAME)
  get_target_property(php_cli_suffix php_cli SUFFIX)
  set(php_cli_filename ${php_cli_basename})
  if(php_cli_suffix)
    string(APPEND php_cli_filename ${php_cli_suffix})
  endif()

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
      -D PHP_BINARY_DIR=${PHP_BINARY_DIR}
      -D php_cli_filename=${php_cli_filename}
      -D CURRENT_SOURCE_DIR=${CMAKE_CURRENT_SOURCE_DIR}
      -D CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR}
      -D INSTALL_FULL_BINDIR=${CMAKE_INSTALL_FULL_BINDIR}
      -P
      ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/GeneratePhar.cmake
    DEPENDS
      php_cli
      ${dependent_files}
    COMMENT "[ext/phar] Generating phar.phar"
  )

  # Create target which consumes the command via DEPENDS. It doesn't execute
  # when cross-compiling, because php executable cannot be run then.
  if(NOT CMAKE_CROSSCOMPILING)
    add_custom_target(
      php_phar_generated_files
      ALL
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
      COMMENT "[ext/phar] Generating phar files"
    )
  endif()
endblock()

# Man documentation.
configure_file(phar.1.in phar.1 @ONLY)
configure_file(phar.phar.1.in phar.phar.1 @ONLY)

install(
  TARGETS php_phar
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)

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
