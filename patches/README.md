# Patches for php-src

This is a collection of patches for various PHP versions in order to use CMake
or due to upstream unresolved bugs. Each patch has a description attached in its
header. They are automatically applied only when using the `bin/init.cmake`,
`bin/init.sh`, or `bin/php.cmake` scripts.

To create a new patch:

```sh
git --no-pager format-patch -1 HEAD --stdout > some.patch
```

To modify existing patches:

```sh
cd php-src
git checkout -b some-patch

# Apply existing patch
git am -3 some.patch

# ... Make and commit changes

# Update some.patch file
git --no-pager format-patch -1 HEAD --stdout > some.patch
```

To update patches against the latest upstream tracking Git branches:

```sh
./bin/update-patches.sh
```
