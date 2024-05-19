#[=============================================================================[
Find re2c.

The minimum required version of re2c can be specified using the standard CMake
syntax, e.g. 'find_package(RE2C 0.15.3)'.

Result variables:

  RE2C_FOUND
    Whether re2c program was found.
  RE2C_VERSION
    Version of re2c program.

Cache variables:

  RE2C_EXECUTABLE
    Path to the re2c program.

Hints:

  RE2C_USE_COMPUTED_GOTOS
    Set to TRUE before calling find_package(RE2C) to enable the re2c
    --computed-gotos option if the non-standard C "computed goto" extension is
    supported by the C compiler.

  RE2C_ENABLE_DOWNLOAD
    This module can also download and build re2c from its Git repository using
    the FetchContent module. Set to TRUE to enable downloading re2c, when not
    found on the system or system version is not suitable.

If re2c is found, the following function is exposed:

  re2c_target(
    <name>
    <input>
    <output>
    [HEADER <header>]
    [OPTIONS <options>...]
    [DEPENDS <depends>...]
  )

    <name>
      Target name.
    <input>
      The re2c template file input. Relative source file path is interpreted as
      being relative to the current source directory.
    <output>
      The output file. Relative output file path is interpreted as being
      relative to the current source directory.
    HEADER
      Generate a <header> file. Relative header file path is interpreted as
      being relative to the current binary directory.
    OPTIONS
      List of additional options to pass to re2c command-line tool.
    DEPENDS
      Optional list of dependent files to regenerate the output file.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)
include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  RE2C
  PROPERTIES
    URL "https://re2c.org/"
    DESCRIPTION "Free and open-source lexer generator"
)

find_program(
  RE2C_EXECUTABLE
  NAMES re2c
  DOC "The re2c executable path"
)

if(RE2C_EXECUTABLE)
  execute_process(
    COMMAND ${RE2C_EXECUTABLE} --vernum
    OUTPUT_VARIABLE RE2C_VERSION_NUM
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  math(
    EXPR RE2C_VERSION_MAJOR
    "${RE2C_VERSION_NUM} / 10000"
  )

  math(
    EXPR RE2C_VERSION_MINOR
    "(${RE2C_VERSION_NUM} - ${RE2C_VERSION_MAJOR} * 10000) / 100"
  )

  math(
    EXPR RE2C_VERSION_PATCH
    "${RE2C_VERSION_NUM} - ${RE2C_VERSION_MAJOR} * 10000 - ${RE2C_VERSION_MINOR} * 100"
  )

  set(RE2C_VERSION "${RE2C_VERSION_MAJOR}.${RE2C_VERSION_MINOR}.${RE2C_VERSION_PATCH}")

  find_package_check_version("${RE2C_VERSION}" _re2c_version_valid)
endif()

if(RE2C_ENABLE_DOWNLOAD AND (NOT RE2C_EXECUTABLE OR NOT _re2c_version_valid))
  include(FetchContent)

  # Set the re2c version to download.
  set(RE2C_VERSION 3.1)

  # Configure re2c.
  set(RE2C_BUILD_RE2GO OFF CACHE INTERNAL "")
  set(RE2C_BUILD_RE2RUST OFF CACHE INTERNAL "")

  # Disable searching for Python as it is not needed in FetchContent build.
  set(CMAKE_DISABLE_FIND_PACKAGE_Python3 TRUE)
  set(Python3_VERSION 3.12)

  set(FETCHCONTENT_QUIET FALSE)

  FetchContent_Declare(
    RE2C
    URL https://github.com/skvadrik/re2c/archive/refs/tags/${RE2C_VERSION}.tar.gz
  )

  FetchContent_MakeAvailable(RE2C)

  # Set executable to re2c target name.
  set(RE2C_EXECUTABLE re2c)

  # Unset temporary variables.
  unset(CMAKE_DISABLE_FIND_PACKAGE_Python3)
  unset(Python3_VERSION)
  unset(FETCHCONTENT_QUIET)
endif()

mark_as_advanced(RE2C_EXECUTABLE)

find_package_handle_standard_args(
  RE2C
  REQUIRED_VARS
    RE2C_EXECUTABLE
    RE2C_VERSION
  VERSION_VAR RE2C_VERSION
  REASON_FAILURE_MESSAGE "re2c not found. Please install re2c."
)

unset(_re2c_version_valid)

if(NOT RE2C_FOUND)
  return()
endif()

# Check for re2c --computed-gotos option.
if(RE2C_USE_COMPUTED_GOTOS)
  message(CHECK_START "Checking for re2c --computed-gotos (-g) option support")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_compiles(C [[
      int main(void) {
      label1:
        ;
      label2:
        ;
        static void *adr[] = { &&label1, &&label2 };
        goto *adr[0];
        return 0;
      }
    ]] _RE2C_HAVE_COMPUTED_GOTOS)
  cmake_pop_check_state()

  if(_RE2C_HAVE_COMPUTED_GOTOS)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

function(re2c_target)
  cmake_parse_arguments(
    PARSE_ARGV
    3
    parsed            # prefix
    ""                # options
    "HEADER"          # one-value keywords
    "OPTIONS;DEPENDS" # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  set(options ${parsed_OPTIONS})

  if(RE2C_USE_COMPUTED_GOTOS AND _RE2C_HAVE_COMPUTED_GOTOS)
    list(APPEND options "--computed-gotos")
  endif()

  set(input ${ARGV1})
  if(NOT IS_ABSOLUTE "${input}")
    set(input ${CMAKE_CURRENT_SOURCE_DIR}/${input})
  endif()

  set(output ${ARGV2})
  if(NOT IS_ABSOLUTE "${output}")
    set(output ${CMAKE_CURRENT_BINARY_DIR}/${output})
  endif()

  set(outputs ${output})

  if(parsed_HEADER)
    set(header ${parsed_HEADER})
    if(NOT IS_ABSOLUTE "${header}")
      set(header ${CMAKE_CURRENT_BINARY_DIR}/${header})
    endif()

    list(APPEND outputs ${header})

    # Before version 1.2 also --bit-vectors (-c) option is required when header
    # option is used.
    if(RE2C_VERSION VERSION_LESS_EQUAL 1.2)
      list(APPEND options "--bit-vectors")
    endif()

    # Since version 3.0, --header is the new alias option for --type-header.
    if(RE2C_VERSION VERSION_GREATER_EQUAL 3.0)
      list(APPEND options --header ${header})
    else()
      list(APPEND options --type-header ${header})
    endif()
  endif()

  add_custom_command(
    OUTPUT ${outputs}
    COMMAND ${RE2C_EXECUTABLE}
      ${options}
      --output ${output}
      ${input}
    DEPENDS ${input} ${parsed_DEPENDS}
    COMMENT "[RE2C][${ARGV0}] Building lexer with re2c ${RE2C_VERSION}"
  )

  add_custom_target(
    ${ARGV0}
    SOURCES ${input}
    DEPENDS ${outputs}
    COMMENT "[RE2C] Building lexer with re2c ${RE2C_VERSION}"
  )
endfunction()
