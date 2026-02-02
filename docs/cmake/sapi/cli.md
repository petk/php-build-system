<!-- This is auto-generated file. -->
* Source code: [sapi/cli/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/cli/CMakeLists.txt)

# The cli SAPI

## Configuration options

### PHP_SAPI_CLI

* Default: `ON`
* Values: `ON|OFF`

Enables the PHP CLI (Command-Line Interpreter/Interface) SAPI executable module.

### PHP_SAPI_CLI_WIN_NO_CONSOLE

* Default: `OFF`
* Values: `ON|OFF`

Builds additional console-less CLI SAPI executable (executable name `php-win`).
Same as the main CLI SAPI (`php`) but without the console (no output is given).

> [!NOTE]
> This option is only available when the target system is Windows.
