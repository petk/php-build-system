# FindEnchant

See: [FindEnchant.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindEnchant.cmake)

## Basic usage

```cmake
include(cmake/FindEnchant.cmake)
```

Find the Enchant library.

Module defines the following `IMPORTED` target(s):

* `Enchant::Enchant` - The package library, if found.

Result variables:

* `Enchant_FOUND` - Whether the package has been found.
* `Enchant_INCLUDE_DIRS` - Include directories needed to use this package.
* `Enchant_LIBRARIES` - Libraries needed to link to the package library.
* `Enchant_VERSION` - Package version, if found.

Cache variables:

* `Enchant_INCLUDE_DIR` - Directory containing package library headers.
* `Enchant_LIBRARY` - The path to the package library.

Hints:

The `Enchant_ROOT` variable adds custom search path.
