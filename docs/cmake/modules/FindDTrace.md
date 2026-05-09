<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindDTrace.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindDTrace.cmake)

# FindDTrace

Finds DTrace and provides command for using it in CMake:

```cmake
find_package(DTrace [...])
```

DTrace (Dynamic Tracing), a comprehensive tracing framework originally developed
by Sun Microsystems for troubleshooting and performance analysis on Unix-like
systems. While the name "DTrace" is associated with the original implementation
(now maintained by the DTrace.org community), there are other compatible
implementations such as SystemTap, which is widely used on Linux systems.

This module specifically detects and uses the SystemTap implementation of
DTrace.

## Imported targets

This module provides the following imported targets:

* `DTrace::DTrace` - The package library, if found.

## Result variables

This module defines the following variables:

* `DTrace_FOUND` - Boolean indicating whether DTrace support was found.

## Cache variables

The following cache variables may also be set:

* `DTrace_INCLUDE_DIR` - Directory containing DTrace library headers.
* `DTrace_EXECUTABLE` - Path to the DTrace command-line utility.

## Commands

This module provides the following commands if DTrace was found:

### `dtrace_target()`

Initializes the DTrace support:

```cmake
dtrace_target(
  <target-name>
  INPUT <input>
  HEADER <header>
  SOURCES <sources>...
  [LINK_LIBRARIES <libs>...]
)
```

This command generates DTrace header `<header>` and creates `INTERFACE` library
`<target-name>` with probe definition object file added as an INTERFACE source.

The arguments are:

* `<target-name>` - DTrace INTERFACE library with the generated DTrace probe
  definition object file.
* `INPUT <input>` - Name of the file with DTrace probe descriptions. Relative
  path is interpreted as being relative to the current source directory.
* `HEADER <header>` - Name of the DTrace probe header file to be generated.
  Relative path is interpreted as being relative to the current binary
  directory.
* `SOURCES <sources>...` - A list of source files to build DTrace object.
  Relative paths are interpreted as being relative to the current source
  directory.
* `LINK_LIBRARIES <libs>...` - Optional. A list of system libraries or CMake
  targets to be linked in the generated DTrace object target.

## Examples

Basic usage:

```cmake
# CMakeLists.txt

find_package(DTrace)

if(DTrace_FOUND)
  dtrace_target(
    foo_dtrace
    INPUT foo_dtrace.d
    HEADER foo_dtrace_generated.h
    SOURCES foo.c ...
  )

  target_link_libraries(foo PRIVATE DTrace::DTrace)
endif()

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
