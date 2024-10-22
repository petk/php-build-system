# PHP/ConfigureFile

See: [ConfigureFile.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/ConfigureFile.cmake)

Wrapper built on top of CMake's `configure_file()`.

There is a common issue with installation prefix not being applied when using
the `--prefix` command-line option at the installation phase:

```sh
cmake --install <build-dir> --prefix <prefix>
```

The following function is exposed:

```cmake
php_configure_file(
  <INPUT <template-file>|CONTENT <template-content>>
  OUTPUT <output-file>
  [VARIABLES [<variable> <value>] ...]
)
```

* `INPUT` or `CONTENT` specify the input template (either a file or a content
  string). Relative <template-file> is interpreted as being relative to the
  current source directory.

* `OUTPUT` specifies the output file. Relative file path is interpreted as being
  relative to the current binary directory.

* `VARIABLES` represent the pairs of variable names and values. Variable values
  support generator expressions.

  The `$<INSTALL_PREFIX>` generator expression can be used in variable values,
  which is replaced with installation prefix either set via the
  `CMAKE_INSTALL_PREFIX` variable at the configuration phase, or the `--prefix`
  option at the `cmake --install` phase.
