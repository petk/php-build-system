<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindDTrace.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindDTrace.cmake)

# FindDTrace

Finds DTrace and provides command for using it in CMake:

```cmake
find_package(DTrace)
```

DTrace (Dynamic Tracing), a comprehensive tracing framework originally developed
by Sun Microsystems for troubleshooting and performance analysis on Unix-like
systems. While the name "DTrace" is associated with the original implementation
(now maintained by the DTrace.org community), there are other compatible
implementations such as SystemTap, which is widely used on Linux systems.

This CMake module specifically detects and uses the SystemTap implementation of
DTrace.

## Imported targets

This module defines the following imported targets:

* `DTrace::DTrace` - The package library, if found.

## Result variables

* `DTrace_FOUND` - Whether DTrace library is found.

## Cache variables

* `DTrace_INCLUDE_DIR` - Directory containing DTrace library headers.
* `DTrace_EXECUTABLE` - Path to the DTrace command-line utility.

## Functions provided by this module

Module defines the following function to initialize the DTrace support.

```cmake
dtrace_target(
  <target-name>
  INPUT <input>
  HEADER <header>
  SOURCES <source>...
  [INCLUDES <includes>...]
)
```

Generates DTrace header `<header>` and creates `INTERFACE` library
`<target-name>` with probe definition object file added as INTERFACE source.

* `<target-name>` - DTrace INTERFACE library with the generated DTrace probe
  definition object file.
* `INPUT` - Name of the file with DTrace probe descriptions. Relative path is
  interpreted as being relative to the current source directory.
* `HEADER` - Name of the DTrace probe header file to be generated. Relative path
  is interpreted as being relative to the current binary directory.
* `SOURCES` - A list of source files to build DTrace object. Relative paths are
  interpreted as being relative to the current source directory.
* `INCLUDES` - A list of include directories for appending to DTrace object.

## Examples

Basic usage:

```cmake
# CMakeLists.txt

find_package(DTrace)

dtrace_target(
  foo_dtrace
  INPUT foo_dtrace.d
  HEADER foo_dtrace_generated.h
  SOURCES foo.c ...
)
target_link_libraries(foo PRIVATE DTrace::DTrace)

add_executable(bar)
target_link_libraries(bar PRIVATE foo_dtrace)
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
