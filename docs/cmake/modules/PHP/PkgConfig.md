<!-- This is auto-generated file. -->
* Source code: [cmake/modules/PHP/PkgConfig.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/PHP/PkgConfig.cmake)

# PHP/PkgConfig

Generate pkg-config .pc file.

CMake at the time of writing doesn't provide an out-of-the-box solution to
generate pkg-config pc files with required libraries to link retrieved from the
targets:
https://gitlab.kitware.com/cmake/cmake/-/issues/22621

Once pkg-config integration is added in CMake natively, this module will be
replaced.

Also there is a common issue with installation prefix not being applied when
using `--prefix` command-line option at the installation phase:

```sh
cmake --install <build-dir> --prefix <prefix>
```

This module provides the following function:

```cmake
php_pkgconfig_generate_pc(
  <pc-template-file>
  <pc-file-output>
  TARGET <target>
  [VARIABLES <variable> <value> ...]
)
```

Generate pkg-config `<pc-file-output>` from the given pc `<pc-template-file>`
template.

* `TARGET`
  Name of the target for getting libraries.
* `VARIABLES`
  Pairs of variable names and values. Variable values support generator
  expressions. For example:

  ```cmake
  php_pkgconfig_generate_pc(
    ...
    VARIABLES
      debug "$<IF:$<CONFIG:Debug>,yes,no>"
      variable "$<IF:$<BOOL:${VARIABLE}>,yes,no>"
  )
  ```

  The `$<INSTALL_PREFIX>` generator expression can be used in variable values,
  which is replaced with installation prefix either set via the
  `CMAKE_INSTALL_PREFIX` variable at the configuration phase, or the `--prefix`
  option at the `cmake --install` phase.

## Basic usage

```cmake
# CMakeLists.txt
include(PHP/PkgConfig)
```
