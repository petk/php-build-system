<!-- This is auto-generated file. -->
* Source code: [cmake/modules/FindSendmail.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSendmail.cmake)

# FindSendmail

This module finds mailer program for PHP and sets sensible defaults based on the
target system:

```cmake
find_package(Sendmail)
```

On Windows, PHP has built-in mailer (sendmail.c), on *nix systems either
`sendmail` is used if found, or a general default value is set to
`/usr/sbin/sendmail`.

## Result variables

* `Sendmail_FOUND` - Boolean indicating whether sendmail was found.
* `Sendmail_PROGRAM` - Path to the sendmail executable program, either found by
  the module or set to a sensible default value for usage in PHP. On Windows,
  this is set to an empty string as PHP uses a built in mailer there.

## Cache variables

* `Sendmail_EXECUTABLE` - Path to the sendmail executable program, if found.

## Examples

Basic usage:

```cmake
# CMakeLists.txt
find_package(Sendmail)
```

## Customizing search locations

To customize where to look for the Sendmail package base
installation directory, a common `CMAKE_PREFIX_PATH` or
package-specific `SENDMAIL_ROOT` variable can be set at
the configuration phase. For example:

```sh
cmake -S <source-dir> \
      -B <build-dir> \
      -DCMAKE_PREFIX_PATH="/opt/Sendmail;/opt/some-other-package"
# or
cmake -S <source-dir> \
      -B <build-dir> \
      -DSENDMAIL_ROOT=/opt/Sendmail \
      -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
