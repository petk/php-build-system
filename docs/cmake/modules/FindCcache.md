<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindCcache.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindCcache.cmake)

# FindCcache

Finds the Ccache compiler cache tool for faster compilation times:

```cmake
find_package(Ccache [<version>] [...])
```

## Result variables

* `Ccache_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `Ccache_VERSION` - The version of package found.

## Cache variables

* `Ccache_EXECUTABLE` - The path to the ccache executable.

## Hints

* The `CCACHE_DISABLE` regular or environment variable which disables ccache and
  doesn't adjust the C and CXX launcher. For more info see Ccache documentation.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Ccache)
```

## Customizing search locations

To customize where to look for the Ccache package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `CCACHE_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Ccache;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DCCACHE_ROOT=/opt/Ccache \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
