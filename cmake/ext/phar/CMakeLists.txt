include(CMakeDependentOption)
include(FeatureSummary)

option(EXT_PHAR "Enable the phar extension" ON)

add_feature_info(
  "ext/phar"
  EXT_PHAR
  "PHP archives (phar) support."
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
      BASE_DIRS "${PHP_SOURCE_DIR}"
      FILES
        php_phar.h
)

target_compile_definitions(php_phar PRIVATE ZEND_ENABLE_STATIC_TSRMLS_CACHE=1)

if(RE2C_FOUND)
  re2c_target(
    NAME php_phar_path_check
    INPUT "${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.re"
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/phar_path_check.c"
    OPTIONS "--no-generation-date -b"
  )
endif()

message(CHECK_START "Checking for phar OpenSSL support")

if(EXT_OPENSSL AND NOT EXT_OPENSSL_SHARED AND NOT BUILD_SHARED_LIBS)
  message(CHECK_PASS "yes, OpenSSL support enabled")
  set(PHAR_HAVE_OPENSSL 1 CACHE INTERNAL "Whether phar has OpenSSL support")
else()
  message(CHECK_FAIL "no, the openssl extension is disabled or shared")
endif()

################################################################################
# Generate files.
################################################################################

get_target_property(php_cli_basename php_cli OUTPUT_NAME)
get_target_property(php_cli_suffix php_cli SUFFIX)
set(php_cli_filename ${php_cli_basename})
if(php_cli_suffix)
  string(APPEND php_cli_filename ${php_cli_suffix})
endif()

file(
  GLOB_RECURSE
  _phar_dependent_files
  ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.inc
  ${CMAKE_CURRENT_SOURCE_DIR}/phar/*.php
)

# TODO: Generate based on CMAKE_CROSSCOMPILING.
# TODO: Fix phar generation when phar is built as shared.

# Generate phar.php.
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  COMMAND
    ${PROJECT_BINARY_DIR}/sapi/cli/${php_cli_filename}
      -n
      -d open_basedir=
      -d output_buffering=0
      -d memory_limit=-1
      -d phar.readonly=0
    ${CMAKE_CURRENT_SOURCE_DIR}/build_precommand.php >
    ${CMAKE_CURRENT_BINARY_DIR}/phar.php
  DEPENDS
    php_cli
    ${CMAKE_CURRENT_SOURCE_DIR}/build_precommand.php
    ${_phar_dependent_files}
  COMMENT "[ext/phar] Generating phar.php"
)

# Generate phar.phar.
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
  COMMAND
    ${PROJECT_BINARY_DIR}/sapi/cli/${php_cli_filename}
      -n
      -d open_basedir=
      -d output_buffering=0
      -d memory_limit=-1
      -d phar.readonly=0
    ${CMAKE_CURRENT_BINARY_DIR}/phar.php pack
      -f ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
      -a pharcommand
      -c auto
      -p 0
      -s ${CMAKE_CURRENT_SOURCE_DIR}/phar/phar.php
      -h sha1
      -b "${CMAKE_INSTALL_FULL_BINDIR}/${php_cli_filename}"
      ${CMAKE_CURRENT_SOURCE_DIR}/phar
  DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/phar.php
    ${_phar_dependent_files}
  COMMENT "[ext/phar] Generating phar.phar"
)

# Create target which consumes the command via DEPENDS.
add_custom_target(php_phar_generated_files ALL
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/phar.phar
  COMMENT "[ext/phar] Generating phar files"
)

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
    "${CMAKE_CURRENT_BINARY_DIR}/phar.1"
    "${CMAKE_CURRENT_BINARY_DIR}/phar.phar.1"
  DESTINATION "${CMAKE_INSTALL_MANDIR}/man1"
)

install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/phar.phar"
  DESTINATION "${CMAKE_INSTALL_BINDIR}"
  # TODO: Adjust permissions.
  PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ
)
