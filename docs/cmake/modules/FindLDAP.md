<!-- This is auto-generated file. -->
# FindLDAP

* Module source code: [FindLDAP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindLDAP.cmake)

Find the LDAP library.

Module defines the following `IMPORTED` target(s):

* `LDAP::LDAP` - The LDAP library, if found.

* `LDAP::LBER` - OpenLDAP LBER Lightweight Basic Encoding Rules library, if
  found. Linked to LDAP::LDAP.

Result variables:

* `LDAP_FOUND` - Whether the package has been found.
* `LDAP_INCLUDE_DIRS` - Include directories needed to use this package.
* `LDAP_LIBRARIES` - Libraries needed to link to the package library.
* `LDAP_VERSION` - Package version, if found.

Cache variables:

* `LDAP_INCLUDE_DIR` - Directory containing package library headers.
* `LDAP_LIBRARY` - The path to the package library.
* `LDAP_LBER_LIBRARY` - The path to the OpenLDAP LBER Lightweight Basic Encoding
  Rules library, if found.

Hints:

The `LDAP_ROOT` variable adds custom search path.

## Basic usage

```cmake
# CMakeLists.txt
find_package(LDAP)
```

## Customizing search locations

To customize where to look for the LDAP package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `LDAP_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/LDAP;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DLDAP_ROOT=/opt/LDAP \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
