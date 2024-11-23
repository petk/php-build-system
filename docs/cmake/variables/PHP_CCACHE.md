# `PHP_CCACHE`

* Default: `ON`
* Values: `ON|OFF`

Enable `ccache` for faster compilation time if it is installed and found on the
system. If not found, it is not used. It can be explicitly turned off with this
option or by setting environment variable `CCACHE_DISABLE=1`. A custom path to
the `ccache` installation directory can be also set with the `CCACHE_ROOT`.
