# `ZEND_MAX_EXECUTION_TIMERS`

Values: `auto|ON|OFF`

Default: `auto`

Zend max execution timers help with timeout and signal handling issues,
especially when thread safety is enabled.

When set to `auto`, the Zend Max execution timers are enabled whether the thread
safety (`PHP_THREAD_SAFETY`) is enabled and whether the target system supports
them. When set to `ON` they get enabled whether the target system supports them
regardless of the `PHP_THREAD_SAFETY` option. When set to `OFF`, they are always
disabled.

This configuration is not available on Windows.
