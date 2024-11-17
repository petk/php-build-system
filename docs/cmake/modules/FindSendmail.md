<!-- This is auto-generated file. -->
# FindSendmail

* Module source code: [FindSendmail.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSendmail.cmake)

Find the `sendmail` program.

## Result variables

* `Sendmail_FOUND` - Whether sendmail has been found.

## Cache variables

* `Sendmail_EXECUTABLE` - Path to the sendmail executable, if found.
* `PROG_SENDMAIL` - Path to the sendmail program.

## Basic usage

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
cmake -S <source-dir> -B <build-dir> -DCMAKE_PREFIX_PATH="/opt/Sendmail;/opt/some-other-package"
# or
cmake -S <source-dir> \
    -B <build-dir> \
    -DSENDMAIL_ROOT=/opt/Sendmail \
    -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
```
