# CMake-based PHP build system

## Index

* [1. Interface library](#1-interface-library)
* [2. PHP CMake modules](#2-php-cmake-modules)
  * [2.1. SearchLibraries](#21-searchlibraries)
  * [2.2. CheckBuiltin](#22-checkbuiltin)
* [3. PHP extensions](#3-php-extensions)
  * [3.1. Properties](#31-properties)

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

All PHP CMake utility modules are located in the `cmake/modules/PHP` directory.

Here are listed only those that are important when adapting PHP build system.
Otherwise, a new module can be added by creating a new CMake file
`cmake/modules/PHP/NewModule.cmake` and then include it in the CMake code:

```cmake
include(PHP/NewModule)
```

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

### 2.2. CheckBuiltin

The `CheckBuiltin` module exposes `php_check_builtin` function to check various
sorts of builtins:

```cmake
include(PHP/CheckBuiltin)

php_check_builtin(__builtin_clz PHP_HAVE_BUILTIN_CLZ)
```

## 3. PHP extensions

To build PHP extensions with CMake, a `CMakeLists.txt` file needs to be added to
the extension's source directory.

Example of `CMakeLists.txt` for PHP extensions can be found in the
`ext/skeleton` directory.

### 3.1. Properties

Extensions can utilize the following custom CMake properties:

* `PHP_ZEND_EXTENSION`

  This property designates the extension as a Zend extension rather than a
  standard PHP extension. Zend extensions function similarly to regular PHP
  extensions, but they are loaded using the `zend_extension` INI directive and
  possess an internally distinct structure with additional hooks. Typically
  employed for advanced functionalities like debuggers and profilers, Zend
  extensions offer enhanced capabilities.

  ```cmake
  set_target_properties(php_<extension_name> PROPERTIES PHP_ZEND_EXTENSION TRUE)
  ```
