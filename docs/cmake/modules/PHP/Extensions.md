# PHP/Extensions

See: [Extensions.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/Extensions.cmake)

Add subdirectories of PHP extensions via `add_subdirectory()`.

This module is responsible for traversing `CMakeLists.txt` files of PHP
extensions and adding them via `add_subdirectory()`. It sorts extension
directories based on the optional directory property `PHP_PRIORITY` value and
the dependencies listed in the `add_dependencies()`. If an extension has
specified dependencies, this module ensures that all dependencies are enabled.
If any of the dependencies are built as `SHARED` libraries, the extension must
also be built as a `SHARED` library.

Dependencies can be specified on top of the CMake's built-in command
`add_dependencies()`, which builds target dependencies before the target itself.
This module reads the `add_dependencies()` invocations in extensions and
automatically enables and configures them as `SHARED` depending on the
configuration if they haven't been explicitly configured. If it fails to
configure extension dependencies automatically it will result in a fatal error
during the configuration phase.

Order of the extensions is then used in the generated
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

TODO: Improve this or simplify the sorting complexities in its entierity. PHP
dependencies are handled very basically ATM.

## Exposed macro

```cmake
php_extensions_add(subdirectory)
```

## Custom CMake properties

* `PHP_ALL_EXTENSIONS`

  Global property with a list of all PHP extensions in the ext directory.

* `PHP_ALWAYS_ENABLED_EXTENSIONS`

  This global property contains a list of always enabled PHP extensions which
  don't need the `HAVE_<extension-name>` preprocessor macros defined in the PHP
  configuration header and can be considered as part of the core PHP engine.

* `PHP_EXTENSIONS`

  This global property contains a list of all enabled PHP extensions for the
  current configuration. Extensions are sorted by the directory priority (see
  `PHP_PRIORITY` property) and extension dependencies (added with CMake command
  `add_dependencies()`).

* `PHP_PRIORITY`

  This optional directory property controls the order of the PHP extensions
  added with the `add_subdirectory()`. Directory added with `add_subdirectory()`
  won't be visible in the configuration phase for the directories added before.
  Priority number can be used to add the extension subdirectory prior (0..100)
  or later (\>100) to other extensions. By default extensions are sorted
  alphabetically and added in between. This enables having extension variables
  visible in depending extensions.

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
