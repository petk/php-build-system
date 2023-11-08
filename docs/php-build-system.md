# CMake-based PHP build system

* [1. Interface library](#1-interface-library)
* [2. PHP CMake modules](#2-php-cmake-modules)
  * [2.1. SearchLibraries](#21-searchlibraries)

## 1. Interface library

The `php_configuration` library (aliased `PHP::configuration`) holds
project-wide compilation flags, definitions, libraries and include directories.

It is analogous to a global configuration class, where configuration is set
during the configuration phase and then linked to targets that need the
configuration.

It can be linked to a given target:

```cmake
target_link_libraries(target_name PRIVATE PHP::configuration)
```

## 2. PHP CMake modules

### 2.1. SearchLibraries

The `SearchLibraries` module exposes a `php_search_libraries` function:

```cmake
include(PHP/SearchLibraries)

php_search_libraries(
  function_name
  "header.h;header_2.h"
  HAVE_FUNCTION_NAME
  FUNCTION_LIBRARY
  LIBRARIES lib_1 lib_2...
)

if(FUNCTION_LIBRARY)
  target_link_libraries(target PRIVATE ${FUNCTION_LIBRARY})
endif()
```
