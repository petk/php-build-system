# FindMC

See: [FindMC.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindMC.cmake)

## Basic usage

```cmake
include(cmake/FindMC.cmake)
```

Find Windows compatible message compiler (mc.exe or windmc) command-line tool.

Message compiler is installed on Windows as part of the Visual Studio or Windows
SDK. When cross-compiling for Windows, there is also a compatible alternative by
GNU (most commonly available via MinGW binutils packages) - windmc:
https://sourceware.org/binutils/docs/binutils.html#windmc.

Result variables:

* `MC_FOUND` - Whether message compiler is found.

Cache variables:

* `MC_EXECUTABLE` - Path to the message compiler if found.

Hints:

The `MC_ROOT` variable adds custom search path.

Module exposes the following function:

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
* `INPUT` - Input message file to compile.
* `HEADER_DIR` - Set the export directory for headers, otherwise current binary
  directory will be used.
* `RC_DIR` - Set the export directory for rc files.
* `XDBG_DIR` - Where to create the .dbg C include file that maps message IDs to
  their symbolic name.
* `OPTIONS` - A list of additional options to pass to message compiler tool.
* `DEPENDS` - Optional list of dependent files to recompile message file.
