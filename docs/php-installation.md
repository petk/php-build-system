# PHP installation

> [!CAUTION]
> **Before running the `make install` or `cmake --install` command, be aware
> that files will be copied outside of your current build directory.**

## Index

* [1. Introduction](#1-introduction)
* [2. Autotools-based build system](#2-autotools-based-build-system)
* [3. JScript-based Windows build system](#3-jscript-based-windows-build-system)
* [4. CMake-based build system](#4-cmake-based-build-system)
  * [4.1. Installation directory structure](#41-installation-directory-structure)

## 1. Introduction

When we think about installing software, we often imagine downloading a package
and setting it up on the system, ready for immediate use.

PHP can be installed through various methods. On \*nix systems, this typically
involves using package managers (`apt install`, `dnf install`, `apk install`,
`pkg install`, `brew install`), or running all-in-one installers that provide a
preconfigured stack.

However, in the context of a build system, "installation" refers to the process
of preparing a directory structure with compiled files, making them ready for
direct use or for packaging.

During the installation phase, compiled binaries, dynamic libraries, header
files, \*nix man documentation pages, and other related files are copied into a
predefined directory structure. Some files may also be generated or modified
according to the final installation location, known as the
*installation prefix*.

It's important to note that this type of PHP installation is usually managed by
package managers, that handle this process through automated scripts.
Additionally, applying patches to tailor the PHP package to suit the specific
requirements of the target system is a common practice.

## 2. Autotools-based build system

The default way to install PHP using Autotools across the system directories can
be done like this:

```sh
# Build configure script:
./buildconf

# Configure PHP build:
./configure --prefix=/usr

# Build PHP in parallel:
make -j$(nproc)

# Run tests in parallel:
make TEST_PHP_ARGS=-j$(nproc) test

# Finally, copy built files to their system locations:
make INSTALL_ROOT=/stage install
```

The optional `--prefix` configure option sets the location where the built files
layout is put. Default prefix is `/usr/local`. The optional `INSTALL_ROOT`
environment variable can set the parent location where the prefixed built files
layout will be put. By default, it is empty and it is usually used to set the
stage directory to perform additional tasks on the built files before being
packaged or distributed.

> [!NOTE]
> The `INSTALL_ROOT` variable name is used in PHP from the early Autotools days.
> GNU standards, CMake, and other build systems use a more common name
> [`DESTDIR`](https://www.gnu.org/prep/standards/html_node/DESTDIR.html).

The files are then copied to a predefined directory structure. PHP Autotools has
another optional configure option `--with-layout=[GNU|PHP]` (GNU or PHP layout).
It defines the installation directory structure. By default, it is set to a PHP
style directory structure.

Directory locations can be adjusted with several Autoconf default options. Here
only those relevant to PHP are listed:

* `--prefix=PREFIX` - install architecture-independent files in PREFIX;
  Default: `/usr/local`
* `--exec-prefix=EPREFIX` - install architecture-dependent files in EPREFIX;
  Default: `<PREFIX>`
* `--bindir=DIR` - set the user executables location;
  Default: `EXPREFIX/bin`
* `--sbindir=DIR` - set the system root executables location;
  Default: `EPREFIX/sbin`
* `--sysconfdir=DIR` - set the read-only single-machine data location;
  Default: `PREFIX/etc`
* `--localstatedir=DIR` - set the modifiable single-machine data location;
  Default: `PREFIX/var`
* `--runstatedir=DIR` - set the modifiable per-process data location;
  Default: `LOCALSTATEDIR/run`; (Autoconf 2.70+)
* `--libdir=DIR` - set the object code libraries location;
  Default: `EPREFIX/lib`
* `--includedir=DIR` - set the project C header files location;
  Default: `PREFIX/include`
* `--datarootdir=DIR` - set read-only architecture-independent data root;
  Default: `PREFIX/share`
* `--datadir=DIR` - set read-only architecture-independent data location;
  Default: `DATAROOTDIR`
* `--mandir=DIR` - set the man documentation location;
  Default: `DATAROOTDIR/man`

When packaging the PHP built files for certain system, additional environment
variables can help customize the installation locations and PHP package
information:

* `EXTENSION_DIR` - absolute path that overrides path to extensions shared
  objects (`.so`, `.dll`... files). By default, it is set to
  `/usr/local/lib/php/extensions/no-debug-non-zts-20230901` or
  `/usr/local/lib/php/20230901`, when using the `--with-layout=GNU`. To override
  it in the context of the prefix, it can be also set like this:

  ```sh
  ./configure --prefix=/usr EXTENSION_DIR=\${prefix}/lib/php/extensions
  ```

Common practice is to also add program prefix and suffix (for example, to have
`php84` and similar):

* `--program-prefix=PREFIX` - prepends built binaries with given prefix.
* `--program-suffix=SUFFIX` - appends suffix to binaries.

```sh
./configure \
  PHP_BUILD_SYSTEM="Acme Linux" \
  PHP_BUILD_PROVIDER="Acme" \
  PHP_BUILD_COMPILER="GCC" \
  PHP_BUILD_ARCH="x86_64" \
  PHP_EXTRA_VERSION="-acme" \
  EXTENSION_DIR=/path/to/php/extensions \
  --with-layout=GNU \
  --with-pear=\${datadir}/pear \
  --localstatedir=/var \
  --sysconfdir=/etc \
  --program-suffix=84 \
  # ...
```

See `./configure --help` for more information on how to adjust these locations.

Default PHP Autotools directory structure with GNU layout (`--with-layout=GNU`):

```sh
📦 <INSTALL_ROOT>                # 📦                             # Stage directory
└─📂 ${prefix}                   # └─📂 /usr/local                # Installation prefix
  ├─📂 ${bindir}                 #   ├─📂 bin                     # Executable binary directory
  └─📂 ${sysconfdir}             #   └─📂 etc                     # System configuration directory
    ├─📂 php-fpm.d               #     ├─📂 php-fpm.d             # PHP FPM configuration directory
    ├─📄 pear.conf               #     ├─📄 pear.conf             # PEAR configuration file
    └─📄 php-fpm.conf.default    #     └─📄 php-fpm.conf.default  # PHP FPM configuration
  └─📂 ${includedir}             #   └─📂 include                 # System include directory
    └─📂 php                     #     └─📂 php                   # PHP headers
      ├─📂 ext                   #       ├─📂 ext                 # PHP extensions header files
      ├─📂 main                  #       ├─📂 main                # PHP main binding header files
      ├─📂 sapi                  #       ├─📂 sapi                # PHP SAPI header files
      ├─📂 TSRM                  #       ├─📂 TSRM                # PHP TSRM header files
      └─📂 Zend                  #       └─📂 Zend                # Zend engine header files
  └─📂 ${libdir}                 #   └─📂 lib
    └─📂 php                     #     └─📂 php                   # PHP shared libraries, build files, PEAR
      ├─📂 20230901-zts-debug    #       ├─📂 20230901-zts-debug  # PHP shared extensions (*.so files)
      └─📂 build                 #       └─📂 build               # Various PHP development and build files
  ├─📂 ${sbindir}                #   ├─📂 sbin                    # Executable binaries for root privileges
  └─📂 ${datarootdir}            #   └─📂 share                   # Directory with shareable files
    └─📂 ${mandir}               #     └─📂 man
      ├─📂 man1                  #       ├─📂 man1                # PHP man section 1 pages for *nix systems
      └─📂 man8                  #       └─📂 man8                # PHP man section 8 pages for *nix systems
    ├─📂 ${PHP_PEAR}             #     ├─📂 pear                  # PEAR installation directory
    └─📂 php                     #     └─📂 php
      └─📂 fpm                   #       └─📂 fpm                 # Additional FPM static HTML files
  └─📂 ${localstatedir}          #   └─📂 var                     # The Linux var directory
    └─📂 log                     #     └─📂 log                   # Directory for PHP logs
  └─📂 ${runstatedir}            #   └─📂 var/run                 # Runtime data directory
📦 /                             # 📦 /                           # System top level root directory
└─📂 tmp                         # └─📂 tmp                       # System temporary directory
  └─📂 pear                      #   └─📂 pear                    # PEAR temporary directory
    ├─📂 cache                   #     ├─📂 cache
    ├─📂 download                #     ├─📂 download
    └─📂 temp                    #     └─📂 temp
```

This is how the default PHP layout directory structure looks like
(`--with-layout=PHP`). Notice the difference of the shared extensions directory
and the `share` directory being named `php`:

```sh
📦 <INSTALL_ROOT>
└─📂 /usr/local
  ├─📂 bin
  └─📂 etc
    ├─📂 php-fpm.d
    ├─📄 pear.conf
    └─📄 php-fpm.conf.default
  └─📂 include
    └─📂 php
      ├─📂 ext
      ├─📂 main
      ├─📂 sapi
      ├─📂 TSRM
      └─📂 Zend
  └─📂 lib
    └─📂 php
      ├─📂 build
      └─📂 extensions
        └─📂 no-debug-non-zts-20230901  # PHP shared extensions (*.so files)
  └─📂 php                              # Directory with shareable files
    └─📂 man
      ├─📂 man1
      └─📂 man8
    └─📂 php
      └─📂 fpm
  ├─📂 sbin
  └─📂 var
    ├─📂 log
    └─📂 run
📦 /
└─📂 tmp
  └─📂 pear
    └─📂 temp
```

## 3. JScript-based Windows build system

Inside a Windows PowerShell:

```sh
# Clone SDK binary tools Git repository
git clone https://github.com/php/php-sdk-binary-tools C:\php-sdk
cd C:\php-sdk

.\phpsdk-vs17-x64.bat
phpsdk_buildtree phpmaster

git clone https://github.com/php/php-src
cd php-src
phpsdk_deps --update --branch master

# Create Windows configure.bat script
.\buildconf.bat

# Configure PHP build and create Makefile
.\configure.bat --with-prefix=<installation-prefix>

# Build PHP
nmake

# Install built files
nmake install
```

## 4. CMake-based build system

Installing PHP with CMake can be done in a similar way:

```sh
# Configuration and generation of build system files:
cmake -DCMAKE_INSTALL_PREFIX="/usr" .

# Build PHP in parallel:
cmake --build . -j

# Run tests using ctest utility:
ctest --progress -V

# Finally, copy built files to their system locations:
DESTDIR=/stage cmake --install .

# Or
cmake --install-prefix /usr .
cmake --build . -j
ctest --progress -V
DESTDIR=/stage cmake --install .

# Or
cmake .
cmake --build . -j
ctest --progress -V
DESTDIR=/stage cmake --install . --prefix /usr
```

> [!NOTE]
> The CMake [`DESTDIR`](https://cmake.org/cmake/help/latest/envvar/DESTDIR.html)
> environment variable behaves like the `INSTALL_ROOT` in PHP native
> Autotools-based build system.

* `CMAKE_INSTALL_PREFIX` - absolute path where to install the application;
  \*nix default: `/usr/local`, Windows default:
  `C:/Program Files/${PROJECT_NAME}`

To adjust the installation locations, the
[GNUInstallDirs](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)
module is used to set additional `CMAKE_INSTALL_*` variables. These variables
are by default relative paths. When customized, they can be either relative or
absolute. When changed to absolute values the installation prefix will not be
taken into account. Here only those relevant to PHP are listed:

* `CMAKE_INSTALL_BINDIR`

  Name of the user executables directory. Default: `bin`

* `CMAKE_INSTALL_SBINDIR`

  Name of the system admin executables directory. Default: `sbin`

* `CMAKE_INSTALL_SYSCONFDIR`

  Name of the read-only single-machine data directory. Default: `etc`

* `CMAKE_INSTALL_LOCALSTATEDIR`

  Name of the modifiable single-machine data directory. Default: `var`

* `CMAKE_INSTALL_RUNSTATEDIR`

  Name of the run-time variable data directory.
  Default: `${CMAKE_INSTALL_LOCALSTATEDIR/run`

* `CMAKE_INSTALL_LIBDIR`

  Name of the directory containing object code libraries. Default: `lib`, or
  `lib64`, or `lib/x86_64-linux-gnu` depending on the target system

* `CMAKE_INSTALL_INCLUDEDIR`

  Name of the C header files includes directory. Default: `include`

* `CMAKE_INSTALL_DATAROOTDIR`

  Name of the read-only architecture-independent data root directory.
  Default: `share`

* `CMAKE_INSTALL_DATADIR`

  Name of the read-only architecture-independent data directory.
  Default: `${CMAKE_INSTALL_DATAROOTDIR}`

* `CMAKE_INSTALL_MANDIR`

  Name of the man documentation directory. Default: `man`

PHP CMake-based build system specific installation cache variables:

* [`PHP_EXTENSION_DIR`](/docs/cmake/variables/PHP_EXTENSION_DIR.md)

  Path containing shared PHP extensions.

* [`PHP_INCLUDE_PREFIX`](/docs/cmake/variables/PHP_INCLUDE_PREFIX.md)

  The PHP include directory inside the `CMAKE_INSTALL_INCLUDEDIR`.
  Default: `php`

* [`PHP_PEAR_DIR`](/docs/cmake/variables/PHP_PEAR.md)

  The path where PEAR will be installed to.

* [`PHP_PEAR_TEMP_DIR`](/docs/cmake/variables/PHP_PEAR.md)

  Path where PEAR writes temporary files. Default: `/tmp/pear` on \*nix,
  `C:/temp/pear` on Windows.

### 4.1. Installation directory structure

PHP installation directory structure when using CMake:

```sh
📦 $ENV{DESTDIR}                      # 📦
└─📂 ${CMAKE_INSTALL_PREFIX}          # └─📂 /usr/local (Windows: C:/Program Files/${PROJECT_NAME})
  ├─📂 ${CMAKE_INSTALL_BINDIR}        #   ├─📂 bin
  └─📂 ${CMAKE_INSTALL_SYSCONFDIR}    #   └─📂 etc
    ├─📂 php-fpm.d                    #     ├─📂 php-fpm.d
    ├─📄 pear.conf                    #     ├─📄 pear.conf
    └─📄 php-fpm.conf.default         #     └─📄 php-fpm.conf.default
  └─📂 ${CMAKE_INSTALL_INCLUDEDIR}    #   └─📂 include
    └─📂 ${PHP_INCLUDE_PREFIX}        #     └─📂 php
      ├─📂 ext                        #       ├─📂 ext
      ├─📂 main                       #       ├─📂 main
      ├─📂 sapi                       #       ├─📂 sapi
      ├─📂 TSRM                       #       ├─📂 TSRM
      └─📂 Zend                       #       └─📂 Zend
  └─📂 ${CMAKE_INSTALL_LIBDIR}        #   └─📂 lib
    └─📂 php                          #     └─📂 php
      └─📂 build                      #       ├─📂 build
  └─📂 ${PHP_EXTENSION_DIR}           #       └─📂 20230901-zts-Debug...
    └─📂 pkgconfig                    #     └─📂 pkgconfig
      ├─📄 php-embed.pc               #       ├─📄 php-embed.pc
      └─📄 php.pc                     #       └─📄 php.pc
  ├─📂 ${CMAKE_INSTALL_SBINDIR}       #   ├─📂 sbin
  └─📂 ${CMAKE_INSTALL_DATAROOTDIR}   #   └─📂 share
    └─📂 ${CMAKE_INSTALL_MANDIR}      #     └─📂 man
      ├─📂 man1                       #       ├─📂 man1
      └─📂 man8                       #       └─📂 man8
  └─📂 ${CMAKE_INSTALL_DATADIR}       #   └─📂 (share)
    └─📂 php                          #     └─📂 php
      └─📂 fpm                        #       └─📂 fpm
  ├─📂 ${PHP_PEAR_DIR}                #     └─📂 pear (default: share/pear)
  └─📂 ${CMAKE_INSTALL_LOCALSTATEDIR} #   └─📂 var
    └─📂 log                          #     └─📂 log
  └─📂 ${CMAKE_INSTALL_RUNSTATEDIR}   #   └─📂 var/run
└─📂 ${PHP_PEAR_TEMP_DIR}             # └─📂 /tmp/pear (Windows: C:/temp/pear)
  ├─📂 cache                          #   ├─📂 cache
  ├─📂 download                       #   ├─📂 download
  └─📂 temp                           #   └─📂 temp
```

> [!NOTE]
> The `DATAROOTDIR` and `DATADIR` are treated separately to be able to adjust
> only the `DATADIR` with project specific files, while leaving the
> `DATAROOTDIR` intact for man or other files. See
> [GNU](https://www.gnu.org/prep/standards/html_node/Directory-Variables.html)
> for more info.

> [!NOTE]
> The CMake `GNUInstallDirs` module also adjusts GNU-related variables according
> to various standards, so there are some special cases.
>
> When the `CMAKE_INSTALL_PREFIX` is set to `/usr`, the `SYSCONFDIR`,
> `LOCALSTATEDIR`, and `RUNSTATEDIR` become `/etc`, `/var`, and
> `/var/run` instead of `/usr/etc`, and `/usr/var`, and `/usr/var/run`. Similar
> adjustments are done when install prefix is `/` or `/opt/...`. See
> [GNUInstallDirs](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html#special-cases)
> for more info. The [PHP/Install](/docs/cmake/modules/PHP/Install.md) bypasses
> some of these adjustmens inside the `install()` command for convenience.

Instead of setting the installation prefix at the configuration phase using
`CMAKE_INSTALL_PREFIX` variable or `--install-prefix` option, there is
also `installDir` field which can be set in the `CMakePresets.json` or
`CMakeUserPresets.json` file.

Example `CMakeUserPresets.json` file, which can be added to the PHP source code
root directory:

```json
{
  "version": 4,
  "configurePresets": [
    {
      "name": "acme-php",
      "inherits": "all-enabled",
      "displayName": "Acme PHP configuration",
      "description": "Customized PHP build",
      "installDir": "/usr",
      "cacheVariables": {
        "CMAKE_INSTALL_BINDIR": "home/user/.local/bin",
        "PHP_BUILD_SYSTEM": "Acme Linux",
        "PHP_BUILD_PROVIDER": "Acme",
        "PHP_BUILD_COMPILER": "GCC",
        "PHP_BUILD_ARCH": "x86_64",
        "PHP_VERSION_LABEL": "-acme"
      }
    }
  ],
  "buildPresets": [
    {
      "name": "acme-php",
      "configurePreset": "acme-php"
    }
  ],
  "testPresets": [
    {
      "name": "acme-php",
      "configurePreset": "acme-php",
      "output": {"verbosity": "verbose"}
    }
  ]
}
```

Above file *inherits* from the `all-enabled` configuration preset of the default
`CMakePresets.json` file and adjusts the PHP installation.

To build and install using the new preset:

```sh
cmake --preset acme-php
cmake --build --preset acme-php -j
ctest --preset acme-php
cmake --install .
```
