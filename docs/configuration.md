# PHP build configuration

## PHP configuration

* `CMAKE_SKIP_RPATH=OFF|ON`

  Default: `OFF`

  Controls whether to add additional runtime library search paths (runpaths or
  rpath) to executables in build directory and installation directory. These are
  passed in form of `-Wl,-rpath,/additional/path/to/library` at build time.

  See the RUNPATH in the executable:

  ```sh
  objdump -x ./php-src/sapi/cli/php | grep 'R.*PATH'
  ```

* `CMAKE_SKIP_BUILD_RPATH=OFF|ON`

  Default: `OFF`

  Disable runtime library search paths (rpath) in build directory executables.

* `CMAKE_SKIP_INSTALL_RPATH=OFF|ON`

  Default: `OFF`

  Disable runtime library search paths (rpath) in installation directory
  executables.

## PHP SAPI modules configuration

## PHP extensions configuration

* `EXT_PDO_MYSQL=OFF|ON`

  Default: `OFF`

  Whether to enable the pdo_mysql extension.

  * `EXT_PDO_MYSQL_DRIVER=mysqlnd|mysql`

    Default: `mysqlnd`

    Select the MySQL driver for pdo_mysql extension.

  * `EXT_PDO_MYSQL_ROOT`

    Set path to MySQL library.

  * `EXT_PDO_MYSQL_CONFIG`

    Set path to the MySQL config command-line tool.

* `EXT_PDO_ODBC=OFF|ON`

  Default: `OFF`

  Whether to enable the pdo_odbc extension.

  * `EXT_ODBC_TYPE=ibm-db2|iODBC|unixODBC|generic`

    Select the ODBC type.

    Default: `unixODBC`

  * `EXT_PDO_ODBC_ROOT`

    Path to the ODBC library root directory.

  * `EXT_PDO_ODBC_LIBRARY`

    Set the ODBC library name.

  * `EXT_PDO_ODBC_CFLAGS`

    A list of additional ODBC library compile flags.

  * `EXT_PDO_ODBC_LDFLAGS`

    A list of additional ODBC library linker flags.

## Configure and CMake configuration options

A list of Autoconf configuration options and their CMake alternatives.

<table>
  <thead>
    <tr>
      <th>configure</th>
      <th>CMake</th>
      <th>Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="3"><strong>PHP specific configuration</strong></td>
    </tr>
    <tr>
      <td>--enable-rpath</td>
      <td>
        CMAKE_SKIP_RPATH=OFF<br>
        CMAKE_SKIP_INSTALL_RPATH=OFF<br>
        CMAKE_SKIP_BUILD_RPATH=OFF
      </td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--disable-rpath</td>
      <td>
        CMAKE_SKIP_RPATH=ON<br>
        or CMAKE_SKIP_INSTALL_RPATH=ON<br>
        and/or CMAKE_SKIP_BUILD_RPATH=ON
      </td>
      <td></td>
    </tr>
    <tr>
      <td colspan="3"><strong>PHP extensions</strong></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-pdo-mysql</td>
      <td>EXT_PDO_MYSQL=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-mysql</td>
      <td>EXT_PDO_MYSQL=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-mysql=shared</td>
      <td>EXT_PDO_MYSQL_SHARED=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-mysql=/usr</td>
      <td>
        EXT_PDO_MYSQL=ON<br>
        EXT_PDO_MYSQL_DRIVER=mysql
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-mysql=DIR</td>
      <td>
        EXT_PDO_MYSQL=ON<br>
        EXT_PDO_MYSQL_DRIVER=mysql<br>
        EXT_PDO_MYSQL_ROOT=DIR
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-mysql=path/to/mysql_config</td>
      <td>
        EXT_PDO_MYSQL=ON<br>
        EXT_PDO_MYSQL_DRIVER=mysql<br>
        EXT_PDO_MYSQL_CONFIG=path/to/mysql_config
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-pdo-odbc</td>
      <td>EXT_PDO_ODBC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-odbc=flavour</td>
      <td>
        EXT_PDO_ODBC=ON<br>
        EXT_PDO_ODBC_TYPE=flavour
      </td>
      <td>Default flavour: unixODBC</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-odbc=flavour,dir,libname,ldflags,cflags</td>
      <td>
        EXT_PDO_ODBC=ON<br>
        EXT_PDO_ODBC_TYPE=flavour<br>
        EXT_PDO_ODBC_ROOT=dir<br>
        EXT_PDO_ODBC_LIBRARY=libname<br>
        EXT_PDO_ODBC_LDFLAGS=ldflags<br>
        EXT_PDO_ODBC_CFLAGS=cflags
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-pdo-odbc=shared</td>
      <td>EXT_PDO_ODBC_SHARED=ON</td>
      <td></td>
    </tr>
  </tbody>
</table>
