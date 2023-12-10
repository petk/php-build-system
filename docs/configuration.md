# PHP build configuration

## Index

* [1. PHP configuration](#1-php-configuration)
* [2. PHP SAPI modules configuration](#2-php-sapi-modules-configuration)
* [3. PHP extensions configuration](#3-php-extensions-configuration)
* [4. Configure and CMake configuration options](#4-configure-and-cmake-configuration-options)

## 1. PHP configuration

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

## 2. PHP SAPI modules configuration

## 3. PHP extensions configuration

* `EXT_ODBC=OFF|ON`

  Default: `OFF`

  Whether to enable the odbc extension.

  * `EXT_ODBC_TYPE`

    Default: `unixODBC`

    Select the ODBC type. Can be `adabas`, `dbmaker`, `empress-bcs`, `empress`,
    `esoob`, `ibm-db2`, `iODBC`, `sapdb`, `solid`, `unixODBC`, or `generic`.

  * `EXT_ODBC_VERSION`

    Force support for the passed ODBC version. A hex number is expected. Set it
    to empty value to prevent an explicit ODBCVER to be defined. By default it
    is set to the highest supported ODBC version by PHP.

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

  * `EXT_PDO_ODBC_TYPE=ibm-db2|iODBC|unixODBC|generic`

    Default: `unixODBC`

    Select the ODBC type.

  * `EXT_PDO_ODBC_ROOT`

    Path to the ODBC library root directory.

  * `EXT_PDO_ODBC_LIBRARY`

    Set the ODBC library name.

  * `EXT_PDO_ODBC_CFLAGS`

    A list of additional ODBC library compile flags.

  * `EXT_PDO_ODBC_LDFLAGS`

    A list of additional ODBC library linker flags.

## 4. Configure and CMake configuration options

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
      <td></td>
      <td>EXT_ODBC=OFF</td>
      <td>default</td>
    </tr>
    <tr>
      <td></td>
      <td>EXT_ODBC=ON</td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-odbcver</td>
      <td>EXT_ODBC_VERSION="0x0350"</td>
      <td>default: 0x0350</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-odbcver[=HEX]</td>
      <td>EXT_ODBC_VERSION=HEX</td>
      <td>default: 0x0350</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-adabas</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-adabas</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=adabas
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-sapdb</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-sapdb</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=sapdb
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-solid</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-solid</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=solid
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-ibm-db2</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-ibm-db2</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=ibm-db2
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-empress</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-empress</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=empress
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-empress-bcs</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-empress-bcs</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=empress-bcs
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-custom-odbc</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-custom-odbc</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=generic
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-iodbc</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-iodbc</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=iODBC
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-esoob</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-esoob</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=esoob
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-unixODBC</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-unixODBC</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=unixODBC
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--without-dbmaker</td>
      <td></td>
      <td>default</td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-dbmaker</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=dbmaker
      </td>
      <td></td>
    </tr>
    <tr>
      <td>&nbsp;&nbsp;--with-dbmaker=DIR</td>
      <td>
        EXT_ODBC=ON<br>
        EXT_ODBC_TYPE=dbmaker<br>
        ODBC_ROOT=DIR
      </td>
      <td></td>
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
