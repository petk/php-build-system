# `PHP_THREAD_SAFETY`

* Default: `OFF`
* Values: `ON|OFF`

Better known as Zend Thread Safety (ZTS), this feature allows PHP to handle
multiple threads safely in web server environments that require thread-safe
execution.

For instance, if Apache uses PHP with a threaded Multi-Processing Module (MPM)
or on Windows, PHP must be configured and built with `PHP_THREAD_SAFETY` set to
`ON`. Thread safety is also enabled automatically during configuration if a
threaded Apache is detected on the system.

Since enabling thread safety adds complexity to PHP usage and installation due
to separate builds of PHP SAPIs and extensions, it is recommended to enable it
only when necessary. At the time of writing, the non-thread-safe (NTS) PHP build
may be a better choice for most environments.
