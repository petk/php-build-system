<!-- This is auto-generated file. -->
* Source code: [ext/session/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/session/CMakeLists.txt)

# The session extension

This extension provides support for sessions to preserve data across subsequent
accesses.

## Configuration options

### PHP_EXT_SESSION

* Default: `ON`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_SESSION_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.

### PHP_EXT_SESSION_MM

* Default: `OFF`
* Values: `ON|OFF`

Includes libmm support for session storage (only for non-ZTS build).
