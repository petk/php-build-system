<!-- This is auto-generated file. -->
* Source code: [ext/session/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/session/CMakeLists.txt)

# The session extension

Configure the `session` extension.

This extension provides support for sessions to preserve data across subsequent
accesses.

## EXT_SESSION

* Default: `ON`
* Values: `ON|OFF`

Enable the extension.

## EXT_SESSION_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## EXT_SESSION_MM

* Default: `OFF`
* Values: `ON|OFF`

Include libmm support for session storage (only for non-ZTS build).
