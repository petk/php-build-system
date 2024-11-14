#[=============================================================================[
Check system requirements and validate basic configuration.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(FeatureSummary)

################################################################################
# Check whether some minimum supported compiler is used.
################################################################################
if(CMAKE_C_COMPILER_ID STREQUAL "SunPro")
  message(
    FATAL_ERROR
    "Using unsupported compiler: Oracle Developer Studio.\n"
    "Please, install a compatible C compiler such as GNU C or Clang. You can "
    "set CMAKE_C_COMPILER (and CMAKE_CXX_COMPILER) to the compiler path on the "
    "system."
  )
endif()

################################################################################
# Check whether the system uses EBCDIC (not ASCII) as its native character set.
################################################################################
message(CHECK_START "Checking system character set")
if(CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
  # EBCDIC targets are obsolete, assume that target uses ASCII when
  # cross-compiling without emulator.
  set(PHP_IS_EBCDIC_EXITCODE 1)
endif()

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)
  check_source_runs(C [[
    int main(void) { return (unsigned char)'A' != (unsigned char)0xC1; }
  ]] PHP_IS_EBCDIC)
cmake_pop_check_state()

if(PHP_IS_EBCDIC)
  message(CHECK_FAIL "EBCDIC")
  message(FATAL_ERROR "PHP does not support EBCDIC targets")
else()
  message(CHECK_PASS "ASCII")
endif()

################################################################################
# Check if bison and re2c are required.
#
# PHP tarball packaged and released at php.net already contains generated lexer
# and parser files. In such cases these don't need to be generated again. When
# building from a Git repository, bison and re2c are required to be installed so
# files can be generated as part of the build process.
################################################################################
#
# Check if bison is required.
if(
  NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_ini_parser.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_ini_parser.h
  OR NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_language_parser.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_language_parser.h
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/json/json_parser.tab.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/json/json_parser.tab.h
  OR NOT EXISTS ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.h
)
  find_package(BISON 3.0.0)
  set_package_properties(
    BISON
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to generate PHP parser files."
  )
  # Add Bison options based on the build type.
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.32)
    # See: https://gitlab.kitware.com/cmake/cmake/-/merge_requests/9921
    set(PHP_DEFAULT_BISON_FLAGS "-Wall $<$<CONFIG:Release,MinSizeRel>:-l>")
  else()
    set(PHP_DEFAULT_BISON_FLAGS "$<IF:$<CONFIG:Release,MinSizeRel>,-lWall,-Wall>")
  endif()
endif()

# Check if re2c is required.
if(
  NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_language_scanner.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_language_scanner_defs.h
  OR NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_ini_scanner.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_ini_scanner_defs.h
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/json/json_scanner.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/json/php_json_scanner_defs.h
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/pdo/pdo_sql_parser.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/phar/phar_path_check.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/standard/url_scanner_ex.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/standard/var_unserializer.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_lexer.c
)
  if(PHP_RE2C_CGOTO)
    set(RE2C_USE_COMPUTED_GOTOS TRUE)
  endif()

  set(RE2C_ENABLE_DOWNLOAD TRUE)
  set(
    RE2C_DEFAULT_OPTIONS
      --no-generation-date # Suppress date output in the generated file.
      $<$<CONFIG:Release,MinSizeRel>:-i> # Do not output line directives.
  )

  find_package(RE2C 1.0.3)
  set_package_properties(
    RE2C
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to generate PHP lexer files."
  )

  add_dependencies(php_generate_files re2c_generate_files)
endif()

################################################################################
# Find sendmail binary.
################################################################################
find_package(Sendmail)

################################################################################
# Find PHP installed on the system for generating stub files (*_arginfo.h),
# Zend/zend_vm_gen.php, ext/tokenizer/tokenizer_data_gen.php and similar where
# it can be used. Otherwise the built cli sapi is used at the build phase.
# Minimum supported version for gen_stub.php is PHP 7.4.
################################################################################
find_package(PHPSystem 7.4)
