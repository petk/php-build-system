# `PHP_SYSTEM_GLOB`

:green_circle: *New in PHP 8.5.*

* Default: `OFF`
* Values: `ON|OFF`

When enabled, system `glob()` function will be used for PHP glob functionality
instead of the PHP `php_glob()` built-in implementation.

> [!NOTE]
> This option is not available when the target system is Windows.
