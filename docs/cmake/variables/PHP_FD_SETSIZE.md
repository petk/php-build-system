# `PHP_FD_SETSIZE`

* Default: empty on \*nix, `256` on Windows
* Values: integer greater than 0

Set the default value of `FD_SETSIZE` on the target system. This value defines
the maximum number of file descriptors that an `fd_set` object can handle. The
value must be an integer.
