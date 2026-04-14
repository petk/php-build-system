<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindLDAP.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindLDAP.cmake)

# FindLDAP

Finds the LDAP library:

```cmake
find_package(LDAP [<version>] [COMPONENTS <components>...] [...])
```

## Components

This module supports optional components which can be specified using the
`find_package()` command:

```cmake
find_package(
  LDAP
  [COMPONENTS <components>...]
  [OPTIONAL_COMPONENTS <components>...]
  [...]
)
```

Supported components include:

* `LDAP` - Finds the main LDAP library.
* `LBER` - Finds the OpenLDAP LBER (Lightweight Basic Encoding Rules) library.

If no components are specified, by default, the `LDAP` is searched as requied
component and `LBER` as optional component.

## Imported targets

This module provides the following imported targets:

* `LDAP::LDAP` - Target encapsulating the LDAP library usage requirements,
  available if `LDAP` component was found. If also `LBER` component was found,
  the `LDAP::LBER` imported target is also linked in this target for simplicity.
* `LDAP::LBER` - Target encapsulating the OpenLDAP LBER Lightweight Basic
  Encoding Rules library, if LBER library was found.

## Result variables

This module defines the following variables:

* `LDAP_FOUND` - Boolean indicating whether (the requested version of) package
  was found.
* `LDAP_VERSION` - The version of package found.

## Cache variables

The following cache variables may also be set:

* `LDAP_INCLUDE_DIR` - Directory containing package library headers.
* `LDAP_LIBRARY` - The path to the package library.
* `LDAP_LBER_INCLUDE_DIR` - The path to the OpenLDAP LBER library headers, if
  found.
* `LDAP_LBER_LIBRARY` - The path to the OpenLDAP LBER library, if found.

## Hints

This module accepts the following variables before calling `find_package()`:

* `LDAP_USE_STATIC_LIBS` - Set this variable to boolean true to search for
  static libraries.

## Examples

Finding OpenLDAP and linking both LDAP and LBER libraries:

```cmake
# CMakeLists.txt

find_package(LDAP)
target_link_library(example PRIVATE LDAP::LDAP)
```

## Customizing search locations

To customize where to look for the LDAP package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `LDAP_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/LDAP;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DLDAP_ROOT=/opt/LDAP \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
