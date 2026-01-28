# `PHP_ENABLE_TESTING`

* Default: `ON`
* Values: `ON|OFF`

Enables testing via `ctest`. When PHP is the top level project, this option is
automatically enabled. When PHP is used by another CMake project (for example,
via `FetchContent` or as a subdirectory), this option is disabled by default.
