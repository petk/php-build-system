<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindMC.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindMC.cmake)

# FindMC

Finds Windows compatible message compiler (mc.exe or windmc) command-line tool:

```cmake
find_package(MC [...])
```

Message compiler is installed on Windows as part of the Visual Studio or Windows
SDK. When cross-compiling for Windows, there is also a compatible alternative by
GNU (most commonly available via MinGW binutils packages) - windmc:
https://sourceware.org/binutils/docs/binutils.html#windmc.

## Result variables

* `MC_FOUND` - Whether message compiler is found.

## Cache variables

* `MC_EXECUTABLE` - Path to the message compiler if found.

## Commands

This module provides the following command:

```cmake
mc_target(
  NAME <name>
  INPUT <input>
  [HEADER_DIR <header-directory>]
  [RC_DIR <rc-directory>]
  [XDBG_DIR <xdbg-directory>]
  [OPTIONS <options>...]
  [DEPENDS <depends>...]
)
```

* `NAME` - Target name.
* `INPUT` - Input message file to compile. Relative path is interpreted as being
  relative to the current source directory.
* `HEADER_DIR` - Set the export directory for headers, otherwise current binary
  directory will be used.
* `RC_DIR` - Set the export directory for rc files, otherwise current binary
  directory will be used.
* `XDBG_DIR` - Where to create the .dbg C include file that maps message IDs to
  their symbolic name.
* `OPTIONS` - A list of additional options to pass to message compiler tool.
* `DEPENDS` - Optional list of dependent files to recompile message file.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(MC)
mc_target(...)
```

## Customizing search locations

To customize where to look for the MC package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `MC_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/MC;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DMC_ROOT=/opt/MC \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
