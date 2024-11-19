<!-- This is auto-generated file. -->
# FindLDAP

* Module source code: [FindLDAP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindLDAP.cmake)

Find the LDAP library.

## Components

* `LDAP` - the main LDAP library
* `LBER` - the OpenLDAP LBER (Lightweight Basic Encoding Rules) library

Module defines the following `IMPORTED` target(s):

* `LDAP::LDAP` - The LDAP library, if found.
* `LDAP::LBER` - OpenLDAP LBER Lightweight Basic Encoding Rules library, if
  found.

## Result variables

* `LDAP_FOUND` - Whether the package has been found.
* `LDAP_INCLUDE_DIRS` - Include directories needed to use this package.
* `LDAP_LIBRARIES` - Libraries needed to link to the package library.
* `LDAP_VERSION` - Package version, if found.

## Cache variables

* `LDAP_INCLUDE_DIR` - Directory containing package library headers.
* `LDAP_LIBRARY` - The path to the package library.
* `LDAP_LBER_INCLUDE_DIR` - The path to the OpenLDAP LBER library headers, if
  found.
* `LDAP_LBER_LIBRARY` - The path to the OpenLDAP LBER library, if found.

## Basic usage

When OpenLDAP is found, both LDAP and LBER libraries are linked in for
convenience.

```cmake
find_package(LDAP)
target_link_library(some_project_target PRIVATE LDAP::LDAP)
```

When working with specific components, LDAP and LBER are linked separately.

```cmake
find_package(LDAP COMPONENTS LDAP LBER)
target_link_library(some_project_target PRIVATE LDAP::LDAP LDAP::LBER)
```

To use only the LBER component:

```cmake
find_package(LDAP COMPONENTS LBER)
target_link_library(some_project_target PRIVATE LDAP::LBER)
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