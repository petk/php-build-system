# PHP/ConfigureFile

Wrapper built on top of CMake's `configure_file()`.

There is a common issue with installation prefix not being applied when using
the `--prefix` command-line option at the installation phase:

```sh
cmake --install <build-dir> --prefix <prefix>
```

The following function is exposed:

```cmake
php_configure_file(
  <template-file>
  <output-file>
  [VARIABLES [<variable> <value>] ...]
)
```

* `VARIABLES`

  Pairs of variable names and values.

  The `$<INSTALL_PREFIX>` generator expression can be used in variable values,
  which is replaced with installation prefix either set via the
  `CMAKE_INSTALL_PREFIX` variable at the configuration phase, or the `--prefix`
  option at the `cmake --install` phase.

  The custom PHP specific `$<PHP_EXPAND:path>` generator expression can be used
  in variable values. It is automatically replaced to `<install-prefix>/path`
  if `path` is relative, or to just `path` if `path` is absolute.
