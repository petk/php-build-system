<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindNetSnmp.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindNetSnmp.cmake)

# FindNetSnmp

Find the Net-SNMP library.

Module defines the following `IMPORTED` target(s):

* `NetSnmp::NetSnmp` - The package library, if found.

## Result variables

* `NetSnmp_FOUND` - Whether the package has been found.
*` NetSnmp_INCLUDE_DIRS` - Include directories needed to use this package.
*` NetSnmp_LIBRARIES` - Libraries needed to link to the package library.
* `NetSnmp_VERSION` - Package version, if found.

## Cache variables

* `NetSnmp_INCLUDE_DIR` - Directory containing package library headers.
* `NetSnmp_LIBRARY` - The path to the package library.
* `NetSnmp_EXECUTABLE` - Path to net-snmp-config utility.

## Basic usage

```cmake
# CMakeLists.txt
find_package(NetSnmp)
```

## Customizing search locations

To customize where to look for the NetSnmp package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `NETSNMP_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/NetSnmp;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DNETSNMP_ROOT=/opt/NetSnmp \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
