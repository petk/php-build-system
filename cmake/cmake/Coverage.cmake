#[=============================================================================[
Code coverage configuration.
#]=============================================================================]

if(NOT PHP_COVERAGE)
  return()
endif()

find_package(Coverage)
set_package_properties(
  Coverage
  PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable code coverage."
)

if(NOT TARGET Coverage::Coverage)
  return()
endif()

target_link_libraries(php_config INTERFACE Coverage::Coverage)

# Create a list of PHP SAPIs with genex.
set(php_sapis "")
file(GLOB directories ${CMAKE_CURRENT_SOURCE_DIR}/sapi/*)
foreach(dir ${directories})
  cmake_path(GET dir FILENAME sapi)
  list(APPEND php_sapis "$<TARGET_NAME_IF_EXISTS:php_sapi_${sapi}>")
endforeach()

################################################################################
# Generate code coverage report using gcovr.
################################################################################

find_package(CoverageGcovr 4.2)
set_package_properties(
  CoverageGcovr
  PROPERTIES
    TYPE RECOMMENDED
    PURPOSE "Generates code coverage HTML and XML reports."
)

if(TARGET CoverageGcovr::gcovr)
  file(CONFIGURE OUTPUT gcovr.cfg CONTENT [[
print-summary = yes
gcov-parallel = yes

exclude-throw-branches = yes
exclude-unreachable-branches = yes

exclude = .*/ext/bcmath/libbcmath/.*
exclude = .*/ext/date/lib/.*
exclude = .*/ext/fileinfo/libmagic/.*
exclude = .*/ext/gd/libgd/.*
exclude = .*/ext/hash/sha3/.*
exclude = .*/ext/mbstring/libmbfl/.*
exclude = .*/ext/opcache/jit/libudis86/.*
exclude = .*/ext/pcre/pcre2lib/.*
exclude = .*/Zend/Optimizer/ssa_integrity\.c
exclude = .*/Zend/Optimizer/zend_dump\.c

exclude-lines-by-pattern = .*\b(ZEND_PARSE_PARAMETERS_(START|END|NONE)|Z_PARAM_).*
exclude-lines-by-pattern = \s*(default:\s*)?ZEND_UNREACHABLE\(\);\s*
exclude-lines-by-pattern = \s*if \(ctx->debug_level & ZEND_DUMP_\w+\) \{\s*
exclude-lines-by-pattern = \s*zend_dump_op_array\(.*\);\s*
]] @ONLY)

  if(php_sapis)
    set(depends_argument DEPENDS ${php_sapis})
  else()
    set(depends_argument "")
  endif()

  add_custom_target(
    php_coverage_gcovr_html
    ${depends_argument}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/gcovr_html
    COMMAND
      CoverageGcovr::gcovr
        ${CoverageGcovr_OPTIONS}
        --root ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
        --output ${CMAKE_CURRENT_BINARY_DIR}/gcovr_html/index.html
        --config ${CMAKE_CURRENT_BINARY_DIR}/gcovr.cfg
        --html
        --html-details
        --html-title "PHP code coverage"
    COMMENT "[gcovr] Generating HTML ${CMAKE_CURRENT_BINARY_DIR}/gcovr_html"
    VERBATIM
  )

  add_custom_target(
    php_coverage_gcovr_xml
    ${depends_argument}
    COMMAND
      CoverageGcovr::gcovr
        ${CoverageGcovr_OPTIONS}
        --root ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
        --output ${CMAKE_CURRENT_BINARY_DIR}/gcovr.xml
        --config ${CMAKE_CURRENT_BINARY_DIR}/gcovr.cfg
        --xml
    COMMENT "[gcovr] Generating XML ${CMAKE_CURRENT_BINARY_DIR}/gcovr.xml"
    VERBATIM
  )
endif()

################################################################################
# Generate code coverage report using lcov.
################################################################################

find_package(CoverageLcov 1.10)
set_package_properties(
  CoverageLcov
  PROPERTIES
    TYPE RECOMMENDED
    PURPOSE "Generates code coverage HTML report using lcov."
)

if(TARGET CoverageLcov::lcov AND TARGET CoverageLcov::genhtml)
  add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/php_lcov.info
    COMMAND
      CoverageLcov::lcov
        ${CoverageLcov_lcov_OPTIONS}
        --capture
        --no-external
        --directory ${CMAKE_CURRENT_BINARY_DIR}
        --base-directory ${CMAKE_CURRENT_SOURCE_DIR}
        --output-file ${CMAKE_CURRENT_BINARY_DIR}/php_lcov.info
        --ignore-errors source
    COMMENT "[lcov] Capturing coverage data for php_lcov.info"
    VERBATIM
  )

  set(patterns "")

  if(PHP_EXT_BCMATH)
    list(APPEND patterns "${CMAKE_CURRENT_SOURCE_DIR}/ext/bcmath/libbcmath/*")
  endif()

  if(PHP_EXT_FILEINFO)
    list(APPEND patterns "${CMAKE_CURRENT_SOURCE_DIR}/ext/fileinfo/libmagic/*")
  endif()

  if(PHP_EXT_GD)
    list(APPEND "${CMAKE_CURRENT_SOURCE_DIR}/ext/gd/libgd/*")
  endif()

  if(PHP_EXT_MBSTRING)
    list(APPEND patterns "${CMAKE_CURRENT_SOURCE_DIR}/ext/mbstring/libmbfl/*")
  endif()

  add_custom_command(
    OUTPUT php_coverage_lcov_strip
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/php_lcov.info
    COMMAND
      CoverageLcov::lcov
        ${CoverageLcov_lcov_OPTIONS}
        --output-file ${CMAKE_CURRENT_BINARY_DIR}/php_lcov.info
        --remove ${CMAKE_CURRENT_BINARY_DIR}/php_lcov.info
          */<stdout>
          ${patterns}
          ${CMAKE_CURRENT_SOURCE_DIR}/ext/date/lib/*
          */ext/date/lib/parse_date.re
          */ext/date/lib/parse_iso_intervals.re
          ${CMAKE_CURRENT_SOURCE_DIR}/ext/hash/sha3/*
          ${CMAKE_CURRENT_SOURCE_DIR}/ext/pcre/pcre2lib/*
      --ignore-errors unused
    COMMENT "[lcov] Stripping bundled libraries from php_lcov.info"
    VERBATIM
  )
  set_source_files_properties(php_coverage_lcov_strip PROPERTIES SYMBOLIC TRUE)

  add_custom_target(
    php_coverage_lcov_info
    DEPENDS ${php_sapis} php_coverage_lcov_strip
    COMMENT "[lcov] Generated ${CMAKE_CURRENT_BINARY_DIR}/php_lcov.info"
  )

  add_custom_target(
    php_coverage_lcov_html
    DEPENDS ${php_sapis} php_coverage_lcov_info
    COMMAND
      CoverageLcov::genhtml
        --legend
        --output-directory ${CMAKE_CURRENT_BINARY_DIR}/lcov_html
        --title "PHP code coverage"
        ${CMAKE_CURRENT_BINARY_DIR}/php_lcov.info
    VERBATIM
  )
endif()
