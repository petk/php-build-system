# FindNetSnmp

Find the Net-SNMP library.

Module defines the following `IMPORTED` target(s):

* `NetSnmp::NetSnmp` - The package library, if found.

Result variables:

* `NetSnmp_FOUND` - Whether the package has been found.
*` NetSnmp_INCLUDE_DIRS` - Include directories needed to use this package.
*` NetSnmp_LIBRARIES` - Libraries needed to link to the package library.
* `NetSnmp_VERSION` - Package version, if found.

Cache variables:

* `NetSnmp_INCLUDE_DIR` - Directory containing package library headers.
* `NetSnmp_LIBRARY` - The path to the package library.
* `NetSnmp_EXECUTABLE` - Path to net-snmp-config utility.

Hints:

The `NetSnmp_ROOT` variable adds custom search path.
