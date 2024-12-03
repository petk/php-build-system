<!-- This is auto-generated file. -->
* Source code: [sapi/cli/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/cli/CMakeLists.txt)

# The cli SAPI

Configure the `cli` PHP SAPI.

## SAPI_CLI

* Default: `ON`
* Values: `ON|OFF`

Enable the PHP CLI (Command-Line Interpreter/Interface) SAPI executable module.

## SAPI_CLI_WIN_NO_CONSOLE

* Default: `OFF`
* Values: `ON|OFF`

Build console-less CLI SAPI. Same as the main CLI SAPI but without console (no
output is given).

> [!NOTE]
> This option is only available when the target system is Windows.
