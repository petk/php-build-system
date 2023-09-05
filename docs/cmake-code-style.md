# CMake code style

CMake is pretty forgiving when it comes to code style. Yet, using some frame on
how to code CMake files can improve overall code quality and understanding of
the build system when used by multiple developers.

This repository is following some of the established code style practices from
the CMake ecosystem.

## Code style

* In general the **all-lowercase style** is preferred.

  ```cmake
  add_library(foo foo.c bar_baz.c)
  ```

* **Variable names**

  CMake variables can be categorized into several types:

  * Cache internal variables

    These are set like this:

    ```cmake
    set(VAR <value> CACHE INTERNAL "Documentation string)
    ```

    These should be UPPER_CASE.

  * Cache variables

    ```cmake
    set(VAR 1 CACHE BOOL "Documentation string)
    option(FOO "Documentation string" ON)
    ```

    These should be UPPER_CASE.

  * Local variables

    Variables with a scope inside functions.

    These should be lower_case.

  * Directory variables

    Variables with a scope inside the current `CMakeLists.txt` and its child
    directories with CMake files.

    If variable is meant to be used within other child directories these should
    be UPPER_CASE.

    Since there is no way to limit the scope of such directory variables to only
    current CMake file, the convention is to prefix them with underscore (`_`)
    to indicate they are meant for temporary use only.

* **End commands**

  To make the code easier to read, use empty commands for `endif()`,
  `endfunction()`, `endforeach()`, `endmacro()` and `endwhile()`, `else()`, and
  similar end commands. The optional argument in these is legacy CMake and not
  recommended anymore.

  For example, do this:

  ```cmake
  if(FOO)
    some_command(...)
  else()
    another_command(...)
  endif()
  ```

  and not this:

  ```cmake
  if(BAR)
    some_other_command(...)
  endif(BAR)
  ```

* **Module naming conventions**

The find nodules are in this repository named in form of `FindUPPERCASE.cmake`.
The utility modules are for convenience prefixed with `PHP` and then mostly
following the form of `PHPFooBar.cmake` pattern.

## Macros vs. functions

Functions are preferred over macros because functions have their own variable
scope. Variables inside macros are visible from the outside scope.

## Tools

There are some tools in different state of maintenance but they can be relevant
as they can help with formatting and linting CMake files.

### cmake-format (by cmakelang project)

The [`cmake-format`](https://cmake-format.readthedocs.io/en/latest/) tool can
find formatting issues and sync the CMake code style:

```sh
cmake-format --check <cmake/CMakeLists.txt cmake/...>
```

It can utilize the configuration file (default `cmake-format.[py|json|yaml]`) or
by passing the `--config-files` or `-c` option:

```sh
cmake-format -c path/to/cmake-format.json --check -- <cmake/CMakeLists.txt cmake/...>
```

Default configuration in JSON format can be printed to stdout:

```sh
cmake-format --dump-config json
```

Option `--in-place` or `-i` fixes particular CMake file in-place instead of
dumping the formatted content to stdout:

```sh
cmake-format -i path/to/cmake/file
```

### cmake-lint (by cmakelang project)

The [`cmake-lint`](https://cmake-format.readthedocs.io/en/latest/cmake-lint.html)
tool is part of the cmakelang project and can help with linting CMake files:

```sh
cmake-lint <cmake/CMakeLists.txt cmake/...>
```

### cmakelint

For linting there is also a separate and useful
[cmakelint](https://github.com/cmake-lint/cmake-lint) tool which similarly lints
and helps to better structure CMake files:

```sh
cmakelint <cmake/CMakeLists.txt cmake/...>
```

## See also

For convenience there is a custom helper script added to this repository that
checks CMake files:

```sh
./bin/check-cmake.sh
```

* [CMake developers docs](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html)
