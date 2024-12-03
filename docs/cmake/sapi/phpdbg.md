<!-- This is auto-generated file. -->
* Source code: [sapi/phpdbg/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/sapi/phpdbg/CMakeLists.txt)

# The phpdbg SAPI

Configure the `phpdbg` (interactive PHP debugger) PHP SAPI.

## SAPI_PHPDBG

* Default: `ON`
* Values: `ON|OFF`

Enable the phpdbg SAPI module as an executable.

## SAPI_PHPDBG_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build phpdbg SAPI also as a shared module together with an executable.

## SAPI_PHPDBG_DEBUG

* Default: `OFF`
* Values: `ON|OFF`

Build phpdbg in debug mode to enable additional diagnostic output for developing
and troubleshooting phpdbg itself.

## SAPI_PHPDBG_READLINE

* Default: `OFF`
* Values: `ON|OFF`

Explicitly enable readline support in phpdbg for command history accessible
through arrow keys. Requires the Editline library. If the PHP extension
`readline` is enabled during the build process, the phpdbg readline support is
automatically enabled regardless of this option.

Where to find the Editline installation on the system, can be customized with
the `EDITLINE_ROOT` variable.
