<!-- This is auto-generated file. -->
* Source code: [ext/readline/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/readline/CMakeLists.txt)

# The readline extension

Configure the `readline` extension.

This extension provides interface for using Editline library.

> [!IMPORTANT]
> This extension should be used only with CLI-based PHP SAPIs.

## EXT_READLINE

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## EXT_READLINE_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## EXT_READLINE_LIBREADLINE

:red_circle: *Removed as of PHP 8.4.*

* Default: `OFF`
* Values: `ON|OFF`

Use the GNU Readline library instead of Editline.
