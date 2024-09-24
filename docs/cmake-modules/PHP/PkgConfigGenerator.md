# PHP/PkgConfigGenerator

See: [PkgConfigGenerator.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/PkgConfigGenerator.cmake)

Generate pkg-config .pc file.

CMake at the time of writing doesn't provide a solution to generate pkg-config
pc files with getting clean linked libraries retrieved from the targets:
https://gitlab.kitware.com/cmake/cmake/-/issues/22621

Also there is a common issue with installation prefix not being applied when
using `--prefix` command-line option at the installation phase:

```sh
cmake --install <build-dir> --prefix <prefix>
```

The following function is exposed:

```cmake
pkgconfig_generate_pc(
  <pc-template-file>
  <pc-file-output>
  TARGET <target>
  [INSTALL_DESTINATION <path>]
  [VARIABLES [<variable> <value>] [<variable_2>:BOOL <value_2>...] ...]
  [SKIP_BOOL_NORMALIZATION]
)
```

Generate pkgconfig `<pc-file-output>` from the given pc `<pc-template-file>`
template.

* `TARGET`
  Name of the target for getting libraries.
* `INSTALL_DESTINATION`
  Path to the pkgconfig directory where generated .pc file will be installed to.
  Usually it is `${CMAKE_INSTALL_LIBDIR}/pkgconfig`. If not provided, .pc file
  will not be installed.
* `VARIABLES`
  Pairs of variable names and values. To pass booleans, append ':BOOL' to the
  variable name. For example:

  ```cmake
  pkgconfig_generate_pc(
    ...
    VARIABLES
      variable_name:BOOL "${variable_name}"
  )
  ```

  The `$<INSTALL_PREFIX>` generator expression can be used in variable values,
  which is replaced with installation prefix either set via the
  `CMAKE_INSTALL_PREFIX` variable at the configuration phase, or the `--prefix`
  option at the `cmake --install` phase.

  The custom PHP specific `$<PHP_EXPAND:path>` generator expression can be used
  in variable values. It is automatically replaced to `<install-prefix>/path`
  if `path` is relative, or to just `path` if `path` is absolute.

* `SKIP_BOOL_NORMALIZATION`
  CMake booleans have values `yes`, `no`, `true`, `false`, `on`, `off`, `1`,
  `0`, they can even be case insensitive and so on. By default, all booleans
  (`var:BOOL`, see above) are normalized to values `yes` or `no`. If this option
  is given, boolean values are replaced in .pc template with the CMake format
  instead (they will be replaced to `ON` or `OFF` and similar).
