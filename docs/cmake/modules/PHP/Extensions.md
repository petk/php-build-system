# PHP/Extensions

See: [Extensions.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/Extensions.cmake)

## Basic usage

```cmake
include(PHP/Extensions)
```

Configure PHP extensions.

This module is responsible for parsing `CMakeLists.txt` files of PHP extensions
and sorting extensions based on the dependencies listed in the
`add_dependencies()`. If an extension has specified dependencies, it ensures
that all dependencies are automatically enabled. If any of the dependencies are
built as `SHARED` libraries, the extension must also be built as a `SHARED`
library.

Dependencies can be specified on top of the CMake's built-in command
`add_dependencies()`, which builds target dependencies before the target itself.
This module reads the `add_dependencies()` invocations in extensions
CMakeLists.txt files and automatically enables and configures them as `SHARED`
depending on the configuration if they haven't been explicitly configured. If it
fails to configure extension dependencies automatically it will result in a
fatal error at the end of the configuration phase.

Order of the extensions is then also important in the generated
`main/internal_functions*.c` files (for the list of `phpext_<extension>_ptr` in
the `zend_module_entry php_builtin_extensions`). This is the order of how the
modules are registered into the Zend hash table.

PHP internal API also provides dependencies handling with the
`ZEND_MOD_REQUIRED`, `ZEND_MOD_CONFLICTS`, and `ZEND_MOD_OPTIONAL`, which should
be set in the extension code itself. PHP internally then sorts the extensions
based on the `ZEND_MOD_REQUIRED` and `ZEND_MOD_OPTIONAL`, so build time sorting
shouldn't be taken for granted and is mostly used for php-src builds.

Example why setting dependencies with `ZEND_MOD_REQUIRED` might matter:
https://bugs.php.net/53141

## Custom CMake properties

* `PHP_ZEND_EXTENSION`

  Extensions can utilize this custom target property, which designates the
  extension as a Zend extension rather than a standard PHP extension. Zend
  extensions function similarly to regular PHP extensions, but they are loaded
  using the `zend_extension` INI directive and possess an internally distinct
  structure with additional hooks. Typically employed for advanced
  functionalities like debuggers and profilers, Zend extensions offer enhanced
  capabilities.

  ```cmake
  set_target_properties(php_<extension_name> PROPERTIES PHP_ZEND_EXTENSION TRUE)
  ```

* `PHP_EXTENSION_<extension>_DEPS`

  Global property with a list of all dependencies of <extension> (name of the
  extension as named in ext directory).
