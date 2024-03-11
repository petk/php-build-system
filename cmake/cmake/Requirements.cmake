#[=============================================================================[
Check system requirements and validate basic configuration.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckSourceRuns)
include(CMakePushCheckState)
include(FeatureSummary)

################################################################################
# Check whether the system uses EBCDIC (not ASCII) as its native codeset.
################################################################################
message(CHECK_START "Checking whether system uses EBCDIC")

if(NOT CMAKE_CROSSCOMPILING)
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_runs(C "
      int main(void) {
        return (unsigned char)'A' != (unsigned char)0xC1;
      }
    " _php_is_ebcdic)
  cmake_pop_check_state()
endif()

if(_php_is_ebcdic)
  message(FATAL_ERROR "PHP does not support EBCDIC targets")
else()
  message(CHECK_PASS "OK, using ASCII")
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
  OR NOT EXISTS ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.h
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/json/json_parser.tab.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/json/json_parser.tab.h
)
  find_package(BISON 3.0.0)
  set_package_properties(
    BISON
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to generate PHP parser files."
  )
endif()

# Check if re2c is required.
if(
  NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_language_scanner.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/Zend/zend_ini_scanner.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/json/json_scanner.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/pdo/pdo_sql_parser.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/phar/phar_path_check.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/standard/var_unserializer.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/ext/standard/url_scanner_ex.c
  OR NOT EXISTS ${PHP_SOURCE_DIR}/sapi/phpdbg/phpdbg_lexer.c
)
  if(PHP_RE2C_CGOTO)
    set(RE2C_USE_COMPUTED_GOTOS TRUE)
  endif()

  find_package(RE2C 1.0.3)
  set_package_properties(
    RE2C
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to generate PHP lexer files."
  )
endif()

################################################################################
# Find sendmail binary.
################################################################################
find_package(Sendmail)

################################################################################
# Check if at least one SAPI is enabled.
################################################################################
function(_php_check_enabled_sapis)
  set(at_least_one_sapi_is_enabled FALSE)

  file(
    GLOB_RECURSE
    subdirectories
    LIST_DIRECTORIES TRUE
    ${PHP_SOURCE_DIR}/sapi/*/
    sapi/*/CMakeLists.txt
  )

  foreach(dir ${subdirectories})
    if(NOT EXISTS ${dir}/CMakeLists.txt)
      continue()
    endif()

    cmake_path(GET dir FILENAME sapi_name)
    string(TOUPPER ${sapi_name} sapi_name)

    if(NOT DEFINED SAPI_${sapi_name})
      file(READ ${dir}/CMakeLists.txt content)

      string(
        REGEX MATCH
        "option\\(SAPI_${sapi_name}[ \t\r\n]+.*\"[ \t\r\n]+([A-Z]+)\\)"
        _
        ${content}
      )

      if(CMAKE_MATCH_1 STREQUAL "ON")
        set(at_least_one_sapi_is_enabled TRUE)
        break()
      endif()
    endif()

    if(SAPI_${sapi_name})
      set(at_least_one_sapi_is_enabled TRUE)
      break()
    endif()
  endforeach()

  if(NOT at_least_one_sapi_is_enabled)
    message(
      WARNING
      "None of the PHP SAPIs have been enabled. If this is intentional, you "
      "can disregard this warning."
    )
  endif()
endfunction()

_php_check_enabled_sapis()

################################################################################
# Find Valgrind.
################################################################################
if(PHP_VALGRIND)
  find_package(Valgrind)
  set_package_properties(
    Valgrind
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable Valgrind support."
  )

  target_link_libraries(php_configuration INTERFACE Valgrind::Valgrind)
endif()
