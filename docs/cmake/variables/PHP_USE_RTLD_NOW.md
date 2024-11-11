# `PHP_USE_RTLD_NOW`

* Default: `OFF`
* Values: `ON|OFF`

Use `dlopen` with the `RTLD_NOW` mode flag instead of `RTLD_LAZY` when loading
shared PHP extensions.

> [!NOTE]
> This option is not available when the target system is Windows.
