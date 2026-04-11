#[=============================================================================[
# PHP/AddCommand

This module provides a command to run PHP command-line executable.

Load this module in a CMake project with:

```cmake
include(PHP/AddCommand)
```

A common issue in build systems is the generation of files with the project
program executable. In PHP there are two main issues this module resolves:

* When PHP command-line executable is found on the host system it can be used to
  generate some files during the build phase. This is the most simple and
  developer-friendly way to use as such files can be generated during the build
  phase directly.

* When building php-src and PHP is not found on the host system, ideally those
  files could be also generated after the PHP CLI SAPI executable is built in
  the php-src project itself. However, this can quickly bring cyclic
  dependencies between the target at hand, PHP CLI and the generated files. This
  module provides a fallback to the PHP CLI SAPI executable in this case without
  introducing cyclic dependencies. In such case, inconvenience is that two build
  steps might need to be done in order to generate the entire project once the
  files have been regenerated.

For example, see the `Zend/zend_vm_gen.php` script in php-src repository to
better understand this issue. It is used to generate source files such as
`Zend/zend_vm_execute.h` and uses PHP command-line interpreter if found on the
host system, or the built CLI SAPI executable.

## Commands

This module provides the following commands:

### `php_add_command()`

Adds a build rule to the generated build system and uses either PHP found on the
host, or the built PHP CLI SAPI executable at the end of the build phase:

```cmake
php_add_command(
  <target-name>
  [EXCLUDE_FROM_ALL | AS_TARGET]
  ARGS <arguments>...
  [REQUIRED_EXTENSIONS <extensions>...]
  [OPTIONAL_EXTENSIONS <extensions>...]
  [MIN_PHP_HOST_VERSION <version>]
  [ONLY_HOST_PHP | ONLY_SAPI_CLI]
  [OUTPUT <output-files>...]
  [DEPENDS <dependent-files>...]
  [COMMENT <comment>...]
  [WORKING_DIRECTORY <dir>]
)
```

The arguments are:

* `<target-name>`

  Unique target name providing the PHP command. This target can be also manually
  executed after the configuration phase with:

  ```sh
  cmake --build <build-dir> -t <target-name>
  ```

* `EXCLUDE_FROM_ALL`

  Optional. Indicates that this command should not be automatically executed
  during the build and is intended to be only run explicitly with:

  ```sh
  cmake --build <build-dir> -t <target-name>
  ```

* `AS_TARGET`

  Optional. Indicates that a `add_custom_target()` command will be used to run
  the PHP command instead of the `add_custom_command()` when:

  * building in php-src tree
  * no suitable PHP was found on the host system
  * built PHP CLI SAPI will be used for running the command

  This is intended to avoid cyclic dependencies between targets and PHP CLI SAPI
  executable.

* `ARGS <arguments>...`

  A list of arguments passed to the PHP executable command (the PHP CLI
  executable and options for shared extensions are automatically prepended to
  these arguments).

* `REQUIRED_EXTENSIONS <extensions>...`

  Optional. A list of required PHP extensions for this PHP command. Extensions
  can be listed by their name, e.g., `tokenizer`, `zlib`, etc. If any of the
  specified extensions are not enabled, target isn't added.

* `OPTIONAL_EXTENSIONS <extensions>...`

  Optional. A list of optional PHP extensions for this PHP command. Extensions
  can be listed by their name, e.g., `tokenizer`, `zlib`, etc. Target is added
  regardless whether any of the specified extensions are enabled or not.

* `MIN_PHP_HOST_VERSION <version>`

  Optional. A minimum required PHP version when PHP is found on the host system
  for using PHP command. If insufficient version is found, PHP CLI target from
  the current build will be used instead of the PHP executable from the host
  system. If this argument is not provided, the minimum required PHP version is
  specified by the `find_package(PHP <version>)` requirement when finding PHP on
  the host.

* `ONLY_HOST_PHP` or `ONLY_SAPI_CLI`

  Optional. Specifies, which PHP to use for running the command. If the
  `ONLY_HOST_PHP` option is specified, only the PHP on the host system (if
  found) will be used. Or vice versa, if the `ONLY_SAPI_CLI` option is
  specified, only the built PHP SAPI CLI executable will be used to run the PHP
  command when building inside php-src. If neither option is specified, the
  command first uses the PHP from the host system if found, and if not found
  when building in php-src it falls back to using PHP SAPI CLI executable.

* `OUTPUT <output-files>...`

  A list of files the command is expected to produce. When these output files
  are added, for example, to a list of sources in some project target, then an
  internal dependency is created and the PHP command is executed automatically
  during the build phase (or at the end of the build phase depending). If this
  argument is not provided, no dependency between project targets is created
  internally (used in cases where the PHP command is intended to be executed
  manually after the build phase with
  `cmake --build <build-dir> -t <target-name>`).

  Relative paths are interpreted as being relative to the current binary
  directory (`CMAKE_CURRENT_BINARY_DIR`).

* `DEPENDS <dependent-files>...`

  Optional. A list of files or targets on which the command depends.

  Relative file paths are managed the same way as in the DEPENDS argument of the
  [`add_custom_command()`](https://cmake.org/cmake/help/latest/command/add_custom_command.html)
  command. For clarity, use absolute paths when referring to files.

* `COMMENT <comment>...`

  Optional. A comment that is displayed before the command is executed. If more
  than one `<comment>` string is given, they are concatenated into a single
  string with no separator between them.

* `WORKING_DIRECTORY <dir>`

  Optional. A directory where the PHP command will be executed from. Relative
  paths are interpreted as being relative to the current binary directory
  (`CMAKE_CURRENT_BINARY_DIR`). If not specified, it is set to the current
  binary directory.

This command acts similar to
[`add_custom_command`](https://cmake.org/cmake/help/latest/command/add_custom_command.html)
and
[`add_custom_target()`](https://cmake.org/cmake/help/latest/command/add_custom_target.html)
commands, except that when PHP is not found on the host system, the `DEPENDS`
argument doesn't add dependencies among targets but instead checks their
timestamps manually and executes the assembled PHP command only when needed.

## Examples

### Example: Basic usage

In the following example, this module is used to generate the
`generated_source.c` source file with PHP. The `generate-something.php` PHP
script requires the `tokenizer` extension to be enabled.

```cmake
# CMakeLists.txt

include(PHP/AddCommand)

php_add_command(
  php_generate_something
  AS_TARGET
  ARGS ${CMAKE_CURRENT_SOURCE_DIR}/generate-something.php
  REQUIRED_EXTENSIONS tokenizer
  OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/generated_source.c
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/data.php
  COMMENT "Generating something"
)

target_sources(example PRIVATE main.c generated_source.c)
```

### Example: Creating a target that executes PHP manually

In the following example, this module is used to add a custom build rule that
runs the specified PHP command:

```cmake
include(PHP/AddCommand)

php_add_command(
  php_generate_foo
  EXCLUDE_FROM_ALL
  ARGS ${CMAKE_CURRENT_SOURCE_DIR}/generate-foo.php
  COMMENT "Generating foo"
)
```

This will add a target `php_generate_foo` during the configuration phase, but it
will not be automatically executed. This can be used in specific cases where the
generated file is intended to be generated during the php-src development and
not by the end php-src users. It can be manually called after the configuration
phase:

```sh
# Configuration phase:
cmake -S <source-dir> -B <build-dir>

# Build step with running only the specified target:
cmake --build <build-dir> -t php_generate_foo
```
#]=============================================================================]

include_guard(GLOBAL)

function(php_add_command)
  cmake_parse_arguments(
    PARSE_ARGV
    1
    parsed
    "EXCLUDE_FROM_ALL;AS_TARGET;ONLY_HOST_PHP;ONLY_SAPI_CLI"
    "MIN_PHP_HOST_VERSION;WORKING_DIRECTORY"
    "ARGS;REQUIRED_EXTENSIONS;OPTIONAL_EXTENSIONS;OUTPUT;DEPENDS;COMMENT"
  )

  if(parsed_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: ${parsed_UNPARSED_ARGUMENTS}")
  endif()

  if(NOT ARGV0)
    message(FATAL_ERROR "1st argument (target name) is missing.")
  endif()

  if(TARGET ${ARGV0})
    get_target_property(source_dir ${ARGV0} SOURCE_DIR)
    message(
      FATAL_ERROR
      "${CMAKE_CURRENT_FUNCTION} cannot create target \"${ARGV0}\" because "
      "another target with the same name already exists. The existing target "
      "is a custom target created in source directory \"${source_dir}\"."
    )
  endif()

  if(parsed_EXCLUDE_FROM_ALL AND parsed_AS_TARGET)
    message(FATAL_ERROR "Use either EXCLUDE_FROM_ALL or AS_TARGET, not both.")
  endif()

  if(NOT parsed_ARGS)
    message(FATAL_ERROR "The ARGS argument is missing.")
  endif()

  if(parsed_ONLY_HOST_PHP AND parsed_ONLY_SAPI_CLI)
    message(FATAL_ERROR "Use either ONLY_HOST_PHP or ONLY_SAPI_CLI, not both.")
  endif()

  if(NOT parsed_ONLY_HOST_PHP AND NOT parsed_ONLY_SAPI_CLI)
    set(parsed_ONLY_HOST_PHP TRUE)
    set(parsed_ONLY_SAPI_CLI TRUE)
  endif()

  if(parsed_OUTPUT)
    set(outputs "")

    foreach(output IN LISTS parsed_OUTPUT)
      cmake_path(
        ABSOLUTE_PATH
        output
        BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        NORMALIZE
      )
      list(APPEND outputs "${output}")
    endforeach()

    set(parsed_OUTPUT "${outputs}")
  endif()

  if(NOT parsed_WORKING_DIRECTORY)
    set(parsed_WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
  endif()

  cmake_path(
    ABSOLUTE_PATH
    parsed_WORKING_DIRECTORY
    BASE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    NORMALIZE
  )

  if(parsed_COMMENT)
    list(JOIN parsed_COMMENT "" parsed_COMMENT)
  endif()

  if(parsed_ONLY_HOST_PHP AND (PHP_HOST_FOUND OR TARGET PHP::Interpreter))
    # Check whether building a self-contained PHP extension or in php-src.
    if(TARGET PHP::Interpreter)
      set(php_host_version "${PHP_VERSION}")
      get_target_property(php_host_executable PHP::Interpreter LOCATION)
    else()
      set(php_host_version "${PHP_HOST_VERSION}")
      set(php_host_executable "${PHP_HOST_EXECUTABLE}")
    endif()

    set(use_host_php TRUE)

    if(
      parsed_MIN_PHP_HOST_VERSION
      AND php_host_version VERSION_LESS parsed_MIN_PHP_HOST_VERSION
    )
      set(use_host_php FALSE)
    endif()

    if(use_host_php AND parsed_REQUIRED_EXTENSIONS)
      foreach(extension IN LISTS parsed_REQUIRED_EXTENSIONS)
        # The opcache extension has non-standard name.
        if(extension STREQUAL "opcache")
          set(name "Zend OPcache")
        else()
          set(name "${extension}")
        endif()

        execute_process(
          COMMAND ${php_host_executable} --ri ${name}
          RESULT_VARIABLE code
          OUTPUT_QUIET
          ERROR_QUIET
        )

        if(NOT code EQUAL 0)
          set(use_host_php FALSE)
          break()
        endif()
      endforeach()
    endif()

    if(use_host_php)
      set(all "")

      if(parsed_OUTPUT AND NOT parsed_EXCLUDE_FROM_ALL)
        add_custom_command(
          OUTPUT ${parsed_OUTPUT}
          COMMAND ${php_host_executable} ${parsed_ARGS}
          DEPENDS ${parsed_DEPENDS}
          COMMENT "${parsed_COMMENT}"
          WORKING_DIRECTORY ${parsed_WORKING_DIRECTORY}
          VERBATIM
        )
      elseif(NOT parsed_EXCLUDE_FROM_ALL)
        set(all "ALL")
      endif()

      add_custom_target(
        ${ARGV0}
        ${all}
        COMMAND ${php_host_executable} ${parsed_ARGS}
        COMMENT "${parsed_COMMENT}"
        WORKING_DIRECTORY ${parsed_WORKING_DIRECTORY}
        VERBATIM
      )

      return()
    endif()
  endif()

  if(NOT parsed_ONLY_SAPI_CLI OR NOT PHP_HOMEPAGE_URL)
    return()
  endif()

  if(NOT CMAKE_CROSSCOMPILING)
    set(
      php_executable
      "$<$<TARGET_EXISTS:PHP::sapi::cli>:$<TARGET_FILE:PHP::sapi::cli>>"
    )
  elseif(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
    set(
      php_executable
      "$<$<TARGET_EXISTS:PHP::sapi::cli>:${CMAKE_CROSSCOMPILING_EMULATOR};$<TARGET_FILE:PHP::sapi::cli>>"
    )
  else()
    set(php_executable "")
  endif()

  set(
    script
    ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/PHP/AddCommand/${ARGV0}.cmake
  )

  if((NOT parsed_OUTPUT AND NOT parsed_EXCLUDE_FROM_ALL) OR parsed_AS_TARGET)
    add_custom_target(
      ${ARGV0}_implicit
      ALL
      COMMAND
        ${CMAKE_COMMAND}
        -D "PHP_OUTPUT=${parsed_OUTPUT}"
        -D "PHP_EXECUTABLE=${php_executable}"
        -D "PHP_ARGS=${parsed_ARGS}"
        -D "PHP_OPTIONS=-d;extension_dir=${PHP_BINARY_DIR}/modules/$<CONFIG>"
        -D "PHP_DEPENDS=${parsed_DEPENDS}"
        -P ${script}
      DEPENDS ${parsed_DEPENDS}
      VERBATIM
    )
  elseif(parsed_OUTPUT AND NOT parsed_EXCLUDE_FROM_ALL)
    add_custom_command(
      OUTPUT ${parsed_OUTPUT}
      COMMAND
        ${CMAKE_COMMAND}
        -D "PHP_OUTPUT=${parsed_OUTPUT}"
        -D "PHP_EXECUTABLE=${php_executable}"
        -D "PHP_ARGS=${parsed_ARGS}"
        -D "PHP_OPTIONS=-d;extension_dir=${PHP_BINARY_DIR}/modules/$<CONFIG>"
        -D "PHP_DEPENDS=${parsed_DEPENDS}"
        -P ${script}
      DEPENDS ${parsed_DEPENDS}
      COMMENT ""
      VERBATIM
    )
  endif()

  add_custom_target(
    ${ARGV0}
    COMMAND
      ${CMAKE_COMMAND}
      -D "PHP_OUTPUT=${parsed_OUTPUT}"
      -D "PHP_EXECUTABLE=${php_executable}"
      -D "PHP_ARGS=${parsed_ARGS}"
      -D "PHP_OPTIONS=-d;extension_dir=${PHP_BINARY_DIR}/modules/$<CONFIG>"
      -D "PHP_DEPENDS=${parsed_DEPENDS}"
      -D "PHP_EXECUTE_EXPLICITLY=TRUE"
      -P ${script}
    DEPENDS ${parsed_DEPENDS}
    VERBATIM
  )

  # Run at the end of the configure phase.
  cmake_language(
    EVAL CODE
    "cmake_language(
      DEFER
      DIRECTORY \"${PHP_SOURCE_DIR}\"
      CALL _php_add_command_create_script
      TARGET \"${ARGV0}\"
      SCRIPT \"${script}\"
      WORKING_DIRECTORY \"${parsed_WORKING_DIRECTORY}\"
      REQUIRED_EXTENSIONS \"${parsed_REQUIRED_EXTENSIONS}\"
      OPTIONAL_EXTENSIONS \"${parsed_OPTIONAL_EXTENSIONS}\"
      COMMENT \"${parsed_COMMENT}\"
    )"
  )
endfunction()

function(_php_add_command_create_script)
  cmake_parse_arguments(
    PARSE_ARGV
    0
    parsed
    ""
    "TARGET;SCRIPT;WORKING_DIRECTORY;COMMENT"
    "REQUIRED_EXTENSIONS;OPTIONAL_EXTENSIONS"
  )

  if(TARGET ${parsed_TARGET}_implicit AND TARGET PHP::sapi::cli)
    add_dependencies(${parsed_TARGET}_implicit PHP::sapi::cli)
  endif()

  set(php_skip FALSE)
  set(php_skip_reason "")

  if(NOT TARGET PHP::sapi::cli)
    set(php_skip TRUE)
    set(php_skip_reason "PHP CLI SAPI executable has not been enabled")
  elseif(CMAKE_CROSSCOMPILING AND NOT CMAKE_CROSSCOMPILING_EMULATOR)
    set(php_skip TRUE)
    set(php_skip_reason "PHP is built in cross-compiling mode without emulator")
  endif()

  # Check enabled extensions.
  set(missing_extensions "")
  foreach(extension IN LISTS parsed_REQUIRED_EXTENSIONS)
    if(NOT TARGET PHP::ext::${extension})
      set(php_skip TRUE)
      list(APPEND missing_extensions ${extension})
    endif()
  endforeach()
  if(missing_extensions)
    list(JOIN missing_extensions ", " missing_extensions)
    string(
      APPEND
      php_skip_reason
      " Missing required PHP extensions: ${missing_extensions}"
    )
  endif()

  # Set options for shared extensions.
  set(php_shared_extensions "")
  foreach(
    extension
    IN LISTS
    parsed_REQUIRED_EXTENSIONS
    parsed_OPTIONAL_EXTENSIONS
  )
    if(NOT TARGET PHP::ext::${extension})
      continue()
    endif()

    get_target_property(type PHP::ext::${extension} TYPE)

    if(NOT type STREQUAL "MODULE_LIBRARY")
      continue()
    endif()

    get_target_property(
      is_zend_extension
      PHP::ext::${extension}
      PHP_ZEND_EXTENSION
    )

    if(is_zend_extension)
      list(APPEND php_shared_extensions -d zend_extension=${extension})
    else()
      list(APPEND php_shared_extensions -d extension=${extension})
    endif()
  endforeach()

  # Create a script for PHP/AddCommand module that loops over output files and
  # their dependent input source files and runs the command inside the
  # execute_process(). Expected input variables:
  # * PHP_EXECUTABLE
  # * PHP_ARGS
  # * PHP_OPTIONS
  # * PHP_EXECUTE_EXPLICITLY - Indicates that script was explicitly executed by
  #   the user with: 'cmake --build <dir> -t <target>'
  #   If enabled, timestamp checks are skipped and any warnings are emitted.
  # * PHP_DEPENDS
  # * PHP_OUTPUT
  file(
    CONFIGURE
    OUTPUT ${parsed_SCRIPT}
    CONTENT [=[
      cmake_minimum_required(VERSION 4.3...4.4)

      set(php_comment "@parsed_COMMENT@")

      if(NOT CMAKE_SCRIPT_MODE_FILE)
        message(
          FATAL_ERROR
          "${CMAKE_CURRENT_LIST_FILE} should be run in CMake script mode "
          "(cmake -P)."
        )
      endif()

      if(@php_skip@ OR NOT PHP_EXECUTABLE)
        if(PHP_EXECUTE_EXPLICITLY)
          set(reason "@php_skip_reason@")

          if(NOT reason AND NOT PHP_EXECUTABLE)
            set(reason "PHP_EXECUTABLE is not set.")
          endif()

          string(
            PREPEND
            reason
            "[@parsed_TARGET@] PHP command was not executed. "
          )

          message(WARNING "${reason}")
        endif()

        return()
      endif()

      if(NOT PHP_ARGS)
        message(FATAL_ERROR "Missing PHP_ARGS")
        return()
      endif()

      set(output_exists FALSE)
      foreach(output IN LISTS PHP_OUTPUT)
        if(EXISTS ${output})
          set(output_exists TRUE)
          break()
        endif()
      endforeach()

      if(
        NOT PHP_EXECUTE_EXPLICITLY
        AND PHP_DEPENDS
        AND PHP_OUTPUT
        AND output_exists
      )
        set(needs_update FALSE)

        foreach(input ${PHP_DEPENDS})
          if(NOT EXISTS ${input})
            continue()
          endif()

          foreach(output ${PHP_OUTPUT})
            if("${input}" IS_NEWER_THAN "${output}")
              set(needs_update TRUE)
              break()
            endif()
          endforeach()

          if(needs_update)
            break()
          endif()
        endforeach()

        if(NOT needs_update)
          return()
        endif()
      endif()

      if(php_comment)
        execute_process(
          COMMAND
            ${CMAKE_COMMAND} -E cmake_echo_color --blue --bold "${php_comment}"
        )
      endif()

      set(args "")

      set(php_arguments "")
      set(output_redirected FALSE)
      set(output_file "")

      # The output redirection character '>' doesn't work inside the
      # execute_process(). This bypasses such commands by capturing output into
      # a variable and writes its content into a file.
      foreach(argument ${PHP_ARGS})
        if(argument STREQUAL ">")
          set(output_redirected TRUE)
          list(
            APPEND
            args
            RESULT_VARIABLE result
            OUTPUT_VARIABLE output
            ERROR_VARIABLE error
          )
        elseif(output_redirected AND NOT output_file)
          set(output_file ${argument})
        else()
          list(APPEND php_arguments ${argument})
        endif()
      endforeach()

      execute_process(
        COMMAND
          ${PHP_EXECUTABLE}
          ${PHP_OPTIONS}
          @php_shared_extensions@
          ${php_arguments}
        WORKING_DIRECTORY "@parsed_WORKING_DIRECTORY@"
        ${args}
      )

      if(output_redirected)
        if(result EQUAL 0 AND output_file)
          file(WRITE ${output_file} "${output}")
        else()
          execute_process(COMMAND ${CMAKE_COMMAND} -E echo "${output}")
        endif()

        if(error)
          message(NOTICE "${error}")
        endif()
      elseif(PHP_OUTPUT)
        # Update modification times of output files to not re-run the command on
        # the consecutive build runs.
        file(TOUCH_NOCREATE ${PHP_OUTPUT})
      endif()
    ]=]
    @ONLY
  )
endfunction()
