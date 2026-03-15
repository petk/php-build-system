# `PHP_INSTALL_SBOM_DIR_SUFFIX`

* Default: `PHP`

The name of the directory inside the `lib/sbom/` where to install PHP SBOM files
(`PHP.spdx.json`). For example, `PHP/8.6` to specify version or other
build-related characteristics and have multiple PHP versions installed. If
absolute path needs to be set, configure `CMAKE_INSTALL_LIBDIR` along with this
path.
