#[=============================================================================[
Check system requirements.
]=============================================================================]#

include(CheckCSourceRuns)

# Check whether the system uses EBCDIC (not ASCII) as its native codeset.
message(STATUS "Checking whether system uses EBCDIC")

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
  message(STATUS "OK")
endif()

# Check if bison and re2c are required.
#
# PHP tarball packaged and released at php.net already contains generated lexer
# and parser files. In such cases these don't need to be generated again. When
# building from a Git repository, bison and re2c are required to be installed so
# files can be generated as part of the build process.
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

# Find sendmail binary.
find_package(SENDMAIL)

# Find PHP executable.
find_package(PHP)
