# FindDTrace

See: [FindDTrace.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindDTrace.cmake)

## Basic usage

```cmake
include(cmake/FindDTrace.cmake)
```

Find DTrace.

Result variables:

* `DTrace_FOUND` - Whether DTrace library is found.

Cache variables:

* `DTrace_INCLUDE_DIR` - Directory containing DTrace library headers.
* `DTrace_EXECUTABLE` - Path to the DTrace command-line utility.
* `HAVE_DTRACE` - Whether DTrace support is enabled.

Hints:

The `DTrace_ROOT` variable adds custom search path.

Module defines the following function to initialize the DTrace support.

```cmake
dtrace_target(
  TARGET <target-name>
  INPUT <input>
  HEADER <header>
  SOURCES <source>...
  [INCLUDES <includes>...]
)
```

* `TARGET` - Target name to append the generated DTrace probe definition object
  file.
* `INPUT` - Name of the file with DTrace probe descriptions.
* `HEADER` - Name of the DTrace probe header file.
* `SOURCES` - A list of project source files to build DTrace object.
* `INCLUDES` - A list of include directories for appending to DTrace object.
