<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindDTrace.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindDTrace.cmake)

# FindDtrace

Find DTrace.

## Result variables

* `DTrace_FOUND` - Whether DTrace library is found.

## Cache variables

* `DTrace_INCLUDE_DIR` - Directory containing DTrace library headers.
* `DTrace_EXECUTABLE` - Path to the DTrace command-line utility.
* `HAVE_DTRACE` - Whether DTrace support is enabled.

## Functions provided by this module

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

## Basic usage

```cmake
# CMakeLists.txt
find_package(DTrace)
```

## Customizing search locations

To customize where to look for the DTrace package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `DTRACE_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/DTrace;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DDTRACE_ROOT=/opt/DTrace \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
