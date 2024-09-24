# FindLDAP

See: [FindLDAP.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/FindLDAP.cmake)

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
