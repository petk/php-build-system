# PHP/CheckCopyFileRange

See: [CheckCopyFileRange.cmake](https://github.com/petk/php-build-system/tree/master/cmake/cmake/modules/PHP/CheckCopyFileRange.cmake)

On FreeBSD, `copy_file_range()` works only with the undocumented flag
`0x01000000`. Until the problem is fixed properly, `copy_file_range()` is used
only on Linux.

Cache variables:

* `HAVE_COPY_FILE_RANGE`
  Whether `copy_file_range()` is supported.
