#[=============================================================================[
Find the Gcov coverage programs and features.

Module defines the following IMPORTED targets:

  Gcov::Gcov
    The interface library, if found.

Result variables:

  Gcov_FOUND
    Whether gcov features have been found.

Cache variables:

  HAVE_GCOV
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(Gcov PROPERTIES
  DESCRIPTION "Coverage report - gcov and lcov"
)

set(_reason_failure_message "")

# TODO: Remove all optimization flags.

set(HAVE_GCOV 1 CACHE INTERNAL "Whether to enable GCOV.")

# Generate HTML coverage report.
find_program(Gcov_LCOV_EXECUTABLE lcov)
find_program(Gcov_GENHTML_EXECUTABLE genhtml)
find_program(Gcov_GCOVR_EXECUTABLE gcovr)

if(NOT Gcov_LCOV_EXECUTABLE)
  string(
    APPEND _reason_failure_message
    "\n    Required lcov program was not found."
  )
endif()

if(NOT Gcov_GENHTML_EXECUTABLE)
  string(
    APPEND _reason_failure_message
    "\n    Required genhtml program was not found."
  )
endif()

if(NOT Gcov_GCOVR_EXECUTABLE)
  string(
    APPEND _reason_failure_message
    "\n    Required gcovr program was not found."
  )
endif()

find_package_handle_standard_args(
  Gcov
  REQUIRED_VARS Gcov_LCOV_EXECUTABLE Gcov_GENHTML_EXECUTABLE Gcov_GCOVR_EXECUTABLE
  REASON_FAILURE_MESSAGE "${_reason_failure_message}"
)

unset(_reason_failure_message)

if(Gcov_FOUND AND NOT TARGET Gcov::Gcov)
  add_library(Gcov::Gcov INTERFACE IMPORTED)

  set_target_properties(Gcov::Gcov PROPERTIES
    # Add the special GCC flags.
    INTERFACE_COMPILE_OPTIONS "$<$<COMPILE_LANGUAGE:ASM,C,CXX>:-fprofile-arcs;-ftest-coverage>"
    INTERFACE_LINK_OPTIONS "$<$<COMPILE_LANGUAGE:ASM,C,CXX>:-lgcov;--coverage>"
  )
endif()

# TODO: Fix excludes.
macro(gcov_generate_report)
  file(
    GENERATE
    OUTPUT CMakeFiles/GenerateGcovReport.cmake
    CONTENT "
      message(STATUS \"Generating lcov data for php_lcov.info\")
      execute_process(
        COMMAND ${Gcov_LCOV_EXECUTABLE}
          --capture
          --no-external
          --directory ${PROJECT_BINARY_DIR}
          --output-file ${PROJECT_BINARY_DIR}/php_lcov.info
      )

      message(STATUS \"Stripping bundled libraries from php_lcov.info\")
      file(
        GLOB_RECURSE _php_gcov_excludes
        \"${PROJECT_BINARY_DIR}/ext/bcmath/libbcmath/*\"
        \"${PROJECT_BINARY_DIR}/ext/date/lib/*\"
        \"${PROJECT_BINARY_DIR}/parse_date.re\"
        \"${PROJECT_BINARY_DIR}/parse_iso_intervals.re\"
        \"${PROJECT_BINARY_DIR}/ext/fileinfo/libmagic/*\"
        \"${PROJECT_BINARY_DIR}/ext/gd/libgd/*\"
        \"${PROJECT_BINARY_DIR}/ext/hash/sha3/*\"
        \"${PROJECT_BINARY_DIR}/ext/mbstring/libmbfl/*\"
        \"${PROJECT_BINARY_DIR}/ext/pcre/pcre2lib/*\"
      )
      execute_process(
        COMMAND ${Gcov_LCOV_EXECUTABLE}
          --output-file ${PROJECT_BINARY_DIR}/php_lcov.info
          --remove ${PROJECT_BINARY_DIR}/php_lcov.info */<stdout>
            ${PROJECT_BINARY_DIR}/ext/bcmath/libbcmath/*
            ${PROJECT_BINARY_DIR}/ext/date/lib/*
            */ext/date/lib/parse_date.re
            */ext/date/lib/parse_iso_intervals.re
            ${PROJECT_BINARY_DIR}/ext/fileinfo/libmagic/*
            ${PROJECT_BINARY_DIR}/ext/gd/libgd/*
            ${PROJECT_BINARY_DIR}/ext/hash/sha3/*
            ${PROJECT_BINARY_DIR}/ext/mbstring/libmbfl/*
            ${PROJECT_BINARY_DIR}/ext/pcre/pcre2lib/*
      )

      message(STATUS \"Generating lcov HTML\")
      execute_process(
        COMMAND ${Gcov_GENHTML_EXECUTABLE}
          --legend
          --output-directory ${PROJECT_BINARY_DIR}/lcov_html
          --title \"PHP Code Coverage\"
          ${PROJECT_BINARY_DIR}/php_lcov.info
      )

      message(STATUS \"Generating gcovr HTML\")
      # Clean generated gcov_html directory. Checks are done as safeguards.
      if(
        EXISTS ${PROJECT_BINARY_DIR}/main/php_config.h
        AND EXISTS ${PROJECT_BINARY_DIR}/gcovr_html
      )
        file(REMOVE_RECURSE ${PROJECT_BINARY_DIR}/gcovr_html)
      endif()
      file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/gcovr_html)
      execute_process(
        COMMAND ${Gcov_GCOVR_EXECUTABLE}
          -sr ${PROJECT_BINARY_DIR}
          -o ${PROJECT_BINARY_DIR}/gcovr_html/index.html
          --html
          --html-details
          --exclude-directories ext/date/lib\$
          -e ext/bcmath/libbcmath/.*
          -e ext/date/lib/parse_date.re
          -e ext/date/lib/parse_date.re
          -e ext/date/lib/.*
          -e ext/fileinfo/libmagic/.*
          -e ext/gd/libgd/.*
          -e ext/hash/sha3/.*
          -e ext/mbstring/libmbfl/.*
          -e ext/pcre/pcre2lib/.*
          --gcov-ignore-errors=no_working_dir_found
      )

      message(STATUS \"Generating gcovr XML\")
      # Clean generated gcovr.xml file. Checks are done as safeguards.
      if(
        EXISTS ${PROJECT_BINARY_DIR}/main/php_config.h
        AND EXISTS ${PROJECT_BINARY_DIR}/gcovr.xml
      )
        file(REMOVE_RECURSE ${PROJECT_BINARY_DIR}/gcovr.xml)
      endif()
      execute_process(
        COMMAND ${Gcov_GCOVR_EXECUTABLE}
          -sr ${PROJECT_BINARY_DIR}
          -o ${PROJECT_BINARY_DIR}/gcovr.xml
          --xml
          --exclude-directories ext/date/lib\$
          -e ext/bcmath/libbcmath/.*
          -e ext/date/lib/.*
          -e ext/fileinfo/libmagic/.*
          -e ext/gd/libgd/.*
          -e ext/hash/sha3/.*
          -e ext/mbstring/libmbfl/.*
          -e ext/pcre/pcre2lib/.*
          --gcov-ignore-errors=no_working_dir_found
      )
    "
  )

  add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/php_lcov.info
    COMMAND ${CMAKE_COMMAND} -P "CMakeFiles/GenerateGcovReport.cmake"
    DEPENDS
      php_cli
      # TODO: Add all enabled dependent PHP_SAPI_* targets.
    COMMENT "[GCOV] Generating GCOV coverage report"
  )

  # Create target which consumes the command via DEPENDS.
  add_custom_target(gcov ALL
    DEPENDS ${PROJECT_BINARY_DIR}/php_lcov.info
    COMMENT "[GCOV] Generating GCOV files"
  )
endmacro()
