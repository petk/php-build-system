#[=============================================================================[
# FindRE2C

Find re2c.

The minimum required version of re2c can be specified using the standard CMake
syntax, e.g. 'find_package(RE2C 0.15.3)'.

## Result variables

* `RE2C_FOUND` - Whether re2c program was found.
* `RE2C_VERSION` - Version of re2c program.

## Cache variables

* `RE2C_EXECUTABLE` - Path to the re2c program. When RE2C is downloaded and
  built from source as part of the built (using below ExternalProject), this
  path will not exist until the built phase.

Custom target:

* `re2c_generate_files` - A custom target for generating lexer files:

  ```sh
  cmake --build <dir> -t re2c_generate_files
  ```

  or to add it as a dependency to other targets:

  ```cmake
  add_dependencies(some_target re2c_generate_files)
  ```

## Hints

* `RE2C_DEFAULT_OPTIONS` - A `;-`list of default global options to pass to re2c
  for all `re2c_target()` invocations. Set before calling the
  `find_package(RE2C)`. Options are prepended to additional options passed with
  `re2c_target()` arguments.

* `RE2C_DISABLE_DOWNLOAD` - This module can also download and build re2c from
  its Git repository using the `ExternalProject` module. Set to `TRUE` to
  disable downloading re2c, when it is not found on the system or system version
  is not suitable.

* `RE2C_USE_COMPUTED_GOTOS` - Set to `TRUE` before calling `find_package(RE2C)`
  to enable the re2c `--computed-gotos` option if the non-standard C
  `computed goto` extension is supported by the C compiler.

## Functions provided by this module

If re2c is found, the following function is exposed:

```cmake
re2c_target(
  <name>
  <input>
  <output>
  [HEADER <header>]
  [OPTIONS <options>...]
  [DEPENDS <depends>...]
  [NO_DEFAULT_OPTIONS]
  [NO_COMPUTED_GOTOS]
)
```

* `<name>` - Target name.
* `<input>` - The re2c template file input. Relative source file path is
  interpreted as being relative to the current source directory.
* `<output>` - The output file. Relative output file path is interpreted as
  being relative to the current binary directory.
* `HEADER` - Generate a <header> file. Relative header file path is interpreted
  as being relative to the current binary directory.
* `OPTIONS` - List of additional options to pass to re2c command-line tool.
* `DEPENDS` - Optional list of dependent files to regenerate the output file.
* `NO_DEFAULT_OPTIONS` - If specified, then the options from
  `RE2C_DEFAULT_OPTIONS` are not passed to the re2c invocation.
* `NO_COMPUTED_GOTOS` - If specified when using the `RE2C_USE_COMPUTED_GOTOS`,
  then the computed gotos option is not passed to the re2c invocation.
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

if(NOT TARGET re2c_generate_files)
  add_custom_target(re2c_generate_files)
endif()

find_program(
  RE2C_EXECUTABLE
  NAMES re2c
  DOC "The re2c executable path"
)
mark_as_advanced(RE2C_EXECUTABLE)

if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.29)
  set(_re2cCondition IS_EXECUTABLE ${RE2C_EXECUTABLE})
else()
  set(_re2cCondition EXISTS ${RE2C_EXECUTABLE})
endif()

if(${_re2cCondition})
  execute_process(
    COMMAND ${RE2C_EXECUTABLE} --vernum
    OUTPUT_VARIABLE RE2C_VERSION_NUM
    ERROR_VARIABLE _re2cVersionError
    RESULT_VARIABLE _re2cVersionResult
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  if(NOT _re2cVersionResult EQUAL 0)
    message(
      SEND_ERROR
      "Command \"${RE2C_EXECUTABLE} --vernum\" failed with output:\n"
      "${_re2cVersionError}"
    )
  elseif(RE2C_VERSION_NUM)
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
      "${RE2C_VERSION_NUM} \
      - ${RE2C_VERSION_MAJOR} * 10000 \
      - ${RE2C_VERSION_MINOR} * 100"
    )

    set(
      RE2C_VERSION
      "${RE2C_VERSION_MAJOR}.${RE2C_VERSION_MINOR}.${RE2C_VERSION_PATCH}"
    )

    find_package_check_version("${RE2C_VERSION}" _re2cVersionValid)
  endif()
endif()

set(_re2cRequiredVars RE2C_EXECUTABLE RE2C_VERSION)

if(NOT RE2C_DISABLE_DOWNLOAD AND (NOT RE2C_EXECUTABLE OR NOT _re2cVersionValid))
  # Set the re2c version to download.
  set(RE2C_VERSION 4.0.2)

  include(ExternalProject)

  ExternalProject_Add(
    re2c
    URL
      https://github.com/skvadrik/re2c/archive/refs/tags/${RE2C_VERSION}.tar.gz
    CMAKE_ARGS
      -DRE2C_BUILD_RE2D=OFF
      -DRE2C_BUILD_RE2D=OFF
      -DRE2C_BUILD_RE2GO=OFF
      -DRE2C_BUILD_RE2HS=OFF
      -DRE2C_BUILD_RE2JAVA=OFF
      -DRE2C_BUILD_RE2JS=OFF
      -DRE2C_BUILD_RE2OCAML=OFF
      -DRE2C_BUILD_RE2PY=OFF
      -DRE2C_BUILD_RE2RUST=OFF
      -DRE2C_BUILD_RE2V=OFF
      -DRE2C_BUILD_RE2ZIG=OFF
      -DRE2C_BUILD_TESTS=OFF
    INSTALL_COMMAND ""
  )

  # Set re2c executable.
  ExternalProject_Get_property(re2c BINARY_DIR)
  add_executable(RE2C::RE2C IMPORTED)
  set_target_properties(
    RE2C::RE2C
    PROPERTIES IMPORTED_LOCATION ${BINARY_DIR}/re2c
  )
  add_dependencies(RE2C::RE2C re2c)
  set_property(CACHE RE2C_EXECUTABLE PROPERTY VALUE ${BINARY_DIR}/re2c)
  unset(BINARY_DIR)

  list(PREPEND _re2cRequiredVars _re2cMsg)
  set(_re2cMsg "downloading at build")
endif()

find_package_handle_standard_args(
  RE2C
  REQUIRED_VARS ${_re2cRequiredVars}
  VERSION_VAR RE2C_VERSION
  HANDLE_VERSION_RANGE
  REASON_FAILURE_MESSAGE "re2c not found. Please install re2c."
)

unset(_re2cCondition)
unset(_re2cMsg)
unset(_re2cRequiredVars)
unset(_re2cVersionValid)

if(NOT RE2C_FOUND)
  return()
endif()

# Check for re2c --computed-gotos option.
if(RE2C_USE_COMPUTED_GOTOS)
  message(CHECK_START "Checking for re2c --computed-gotos (-g) option support")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)
    check_source_compiles(C [[
      int main(void)
      {
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
    parsed                                 # prefix
    "NO_DEFAULT_OPTIONS;NO_COMPUTED_GOTOS" # options
    "HEADER"                               # one-value keywords
    "OPTIONS;DEPENDS"                      # multi-value keywords
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Bad arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(parsed_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "Missing values for: ${parsed_KEYWORDS_MISSING_VALUES}")
  endif()

  set(options ${parsed_OPTIONS})

  if(
    RE2C_USE_COMPUTED_GOTOS
    AND _RE2C_HAVE_COMPUTED_GOTOS
    AND NOT parsed_NO_COMPUTED_GOTOS
  )
    list(PREPEND options "--computed-gotos")
  endif()

  if(RE2C_DEFAULT_OPTIONS AND NOT parsed_NO_DEFAULT_OPTIONS)
    list(PREPEND options ${RE2C_DEFAULT_OPTIONS})
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

    # When header option is used before version 1.2, also the '-c' option is
    # required. Before 1.1 -c long variant is '--start-conditions' and after 1.1
    # '--conditions'.
    if(RE2C_VERSION VERSION_LESS_EQUAL 1.2)
      list(APPEND options -c)
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
    DEPENDS ${input} ${parsed_DEPENDS} $<TARGET_NAME_IF_EXISTS:RE2C::RE2C>
    COMMENT "[RE2C][${ARGV0}] Building lexer with re2c ${RE2C_VERSION}"
    VERBATIM
    COMMAND_EXPAND_LISTS
  )

  add_custom_target(
    ${ARGV0}
    SOURCES ${input}
    DEPENDS ${outputs}
    COMMENT "[RE2C] Building lexer with re2c ${RE2C_VERSION}"
  )

  add_dependencies(re2c_generate_files ${ARGV0})
endfunction()
