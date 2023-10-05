#[=============================================================================[
Check system requirements and validate basic configuration.
]=============================================================================]#

include(CheckCSourceRuns)

################################################################################
# Check whether the system uses EBCDIC (not ASCII) as its native codeset.
################################################################################
message(CHECK_START "Checking whether system uses EBCDIC")

if(NOT CMAKE_CROSSCOMPILING)
  check_c_source_runs("
    int main(void) {
      return (unsigned char)'A' != (unsigned char)0xC1;
    }
  " _is_ebcdic)
endif()

if(_is_ebcdic)
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
  NOT EXISTS "${CMAKE_SOURCE_DIR}/Zend/zend_ini_parser.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/Zend/zend_ini_parser.h"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/Zend/zend_language_parser.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/Zend/zend_language_parser.h"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/sapi/phpdbg/phpdbg_parser.h"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/ext/json/json_parser.tab.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/ext/json/json_parser.tab.h"
)
  find_package(BISON 3.0.0 REQUIRED)
endif()

# Check if re2c is required.
if(
  NOT EXISTS "${CMAKE_SOURCE_DIR}/Zend/zend_language_scanner.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/Zend/zend_ini_scanner.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/ext/json/json_scanner.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/ext/pdo/pdo_sql_parser.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/ext/phar/phar_path_check.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/ext/standard/var_unserializer.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/ext/standard/url_scanner_ex.c"
  OR NOT EXISTS "${CMAKE_SOURCE_DIR}/sapi/phpdbg/phpdbg_lexer.c"
)
  find_package(RE2C 1.0.3 REQUIRED)
endif()

################################################################################
# Find sendmail binary.
################################################################################
find_package(SENDMAIL)

################################################################################
# Check if at least one SAPI is enabled.
################################################################################
function(_php_check_enabled_sapis)
  set(at_least_one_sapi_is_enabled FALSE)

  file(
    GLOB_RECURSE
    subdirectories
    LIST_DIRECTORIES TRUE
    "${CMAKE_SOURCE_DIR}/sapi/*/" "sapi/*/CMakeLists.txt"
  )

  foreach(dir ${subdirectories})
    if(NOT EXISTS "${dir}/CMakeLists.txt")
      continue()
    endif()

    cmake_path(GET dir FILENAME sapi_name)
    string(TOUPPER ${sapi_name} sapi_name)

    if(NOT DEFINED SAPI_${sapi_name})
      file(READ "${dir}/CMakeLists.txt" content)

      string(
        REGEX MATCH
        "option\\(SAPI_${sapi_name}[\\r\\n\\t ]*.*\"[\\r\\n\\t ]+([A-Z]+)"
        _
        ${content}
      )

      if(${CMAKE_MATCH_1} STREQUAL "ON")
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
      FATAL_ERROR
      "To build PHP you must enable at least one PHP SAPI module"
    )
  endif()
endfunction()

_php_check_enabled_sapis()

################################################################################
# Find Valgrind.
################################################################################
if(PHP_VALGRIND)
  find_package(VALGRIND REQUIRED)
endif()
