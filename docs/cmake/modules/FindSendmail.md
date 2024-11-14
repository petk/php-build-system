# FindSendmail

See: [FindSendmail.cmake](https://github.com/petk/php-build-system/blob/master/cmake/cmake/modules/FindSendmail.cmake)

## Basic usage

```cmake
include(cmake/FindSendmail.cmake)
```

Find the `sendmail` program.

Result variables:

* `Sendmail_FOUND` - Whether sendmail has been found.

Cache variables:

* `Sendmail_EXECUTABLE` - Path to the sendmail executable, if found.
* `PROG_SENDMAIL` - Path to the sendmail program.
