# `PHP_ZEND_SIGNALS`

* Default: `ON`
* Values: `ON|OFF`

Whether to enable Zend signals handling within the Zend Engine for performance.
When enabled and if the target system supports them, they will be enabled,
otherwise they will be disabled.

See also: https://wiki.php.net/rfc/zendsignals

> [!NOTE]
> This option is not available when the target system is Windows.
