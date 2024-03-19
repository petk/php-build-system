# Patches for php-src

This is a collection of patch files for various PHP versions in order to use
CMake. Each patch has a description attached in its header. They are
automatically applied only when using the `bin/init.sh` or `bin/php.cmake`
scripts.

To recreate these patches on a local machine, a separate `php-src` Git
repository should be cloned next to this repository. At the time of this
writing, they aren't available on GitHub yet.

Patches are then created from the list of the specified Git branches in the
`bin/make-patches.sh` script:

```sh
./bin/make-patches.sh
```
