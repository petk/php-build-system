# CMake code style

This repository is following some best practices from the CMake ecosystem.

## Code style

* In general the all-lowercase style is preferred.

  ```cmake
  add_library(ctype ctype.c)
  ```

* Variable names

  * Variables starting with underscore (`_`) indicate they are meant for
    temporary use only.
  * Cache variables should usually be all UPPER_CASE.

* End commands

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

## Macros vs. functions

Functions are preferred over macros because functions have their own variable
scope. Variables inside macros are visible from the outside scope.

## Tools

There are some tools in different state of maintenance but they can be relevant
as they can help with formatting and linting CMake files.

### cmake-format

The [`cmake-format`](https://cmake-format.readthedocs.io/en/latest/) tool can
find formatting issues and sync the CMake code style:

```sh
cmake-format --check <cmake/CMakeLists.txt cmake/...>
```

It can utilize the configuration file (default `cmake-format.[py|json|yaml]`) or
by passing the `--config-files` or `-c` option:

```sh
cmake-format -c path/to/cmake-format.json --check <cmake/CMakeLists.txt cmake/...>
```

Option `--in-place` or `-i` fixes particular CMake file in-place instead of
dumping the formatted content to STDOUT:

```sh
cmake-format -i path/to/cmake/file
```

### cmake-lint

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
