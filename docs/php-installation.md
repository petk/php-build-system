# PHP installation

> [!CAUTION]
> **Before running the `make install` or `cmake --install` command, be aware
> that files will be copied outside of your current build directory.**

Installation of built files is usually a simple copy to a predefined directory
structure on a given system. In this phase the executable binary files, dynamic
library objects, header files, \*nix man documentation pages, and similar files
are copied to system directories.

Please note that PHP installation on \*nix systems is typically handled by
system package managers through automated scripts. Additionally, it is common
practice to apply additional patches to tailor the PHP package to suit the
specific requirements of the \*nix distribution in use.

## Installing PHP with Autotools-based build system

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
style directory structure:

```sh
🗁 <INSTALL_ROOT>
 └─🗁 /usr
    └─ local
       ├─🗁 bin                      # Executable binary directory
       └─🗁 etc                      # System configuration directory
          ├─🗁 php-fpm.d             # PHP FPM configuration directory
          ├─📄 php-fpm.conf.default  # PHP FPM configuration
          └─📄 pear.conf             # PEAR configuration file
       └─🗁 include
          └─🗁 php                   # PHP headers
             ├─🗁 ext                # PHP extensions header files
             ├─🗁 main               # PHP main binding header files
             ├─🗁 sapi               # PHP SAPI header files
             ├─🗁 TSRM               # PHP TSRM header files
             └─🗁 Zend               # Zend engine header files
       └─🗁 lib
          └─🗁 php                   # PHP shared libraries and other build files, PEAR files
             ├─🗁 build              # Various PHP development and build files
             └─🗁 extensions
                └─🗁 no-debug-non-zts-20230901 # PHP shared extensions (*.so files)
       └─🗁 php
          └─🗁 man
             ├─🗁 man1               # PHP man section 1 pages for *nix systems
             └─🗁 man8               # PHP man section 8 pages for *nix systems
          └─🗁 php
             └─🗁 fpm                # Additional FPM static HTML files
       ├─🗁 sbin                     # Executable binaries for root privileges
       └─🗁 var                      # The Linux var directory
          ├─🗁 log                   # Directory for PHP logs
          └─🗁 run                   # Runtime data directory
```

This is how the GNU layout directory structure looks like (`--with-layout=GNU`):

```sh
🗁 <INSTALL_ROOT>
 └─🗁 usr
    └─🗁 local
       ├─🗁 bin
       └─🗁 etc
          ├─🗁 php-fpm.d
          ├─📄 php-fpm.conf.default
          └─📄 pear.conf
       └─🗁 include
          └─🗁 php
             ├─🗁 ext
             ├─🗁 main
             ├─🗁 sapi
             ├─🗁 TSRM
             └─🗁 Zend
       └─🗁 lib
          └─🗁 php
             ├─🗁 20230901         # PHP shared extensions (*.so files)
             └─🗁 build
       ├─🗁 sbin
       └─🗁 share                  # Directory with shareable files
          └─🗁 man
             ├─🗁 man1
             └─🗁 man8
          └─🗁 pear                # PEAR files
          └─🗁 php
             └─🗁 fpm
       └─🗁 var
          ├─🗁 log
          └─🗁 run
```

Notice the difference of the shared extensions and the share directory.

Directory locations can be adjusted with several Autoconf default options:

* `--bindir=DIR` - set the user executables location
* `--datadir=DIR` - set read-only architecture-independent data
* `--datarootdir=DIR` - set read-only arch.-independent data root
* `--includedir=DIR` - set the project C header files location
* `--libdir=DIR` - set the library location
* `--localstatedir=DIR` - set the var location
* `--mandir=DIR` - set the man documentation location
* `--runstatedir=DIR` - set the run location (Autoconf 2.70+)
* `--sbindir=DIR` - set the root executables location
* `--sysconfdir=DIR` - set the etc location
* ...

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
  --localstatedir=/var \
  --program-suffix=84 \
  # ...
```

See `./configure --help` for more information on how to adjust these locations.

PHP Autotools directory structure with GNU layout:

```sh
🗁 <INSTALL_ROOT>                     # 🗁
 └─🗁 ${prefix}                       # └─🗁 /usr/local/include
    ├─🗁 ${bindir}                    #    ├─🗁 bin
    └─🗁 ${sysconfdir}                #    └─🗁 etc
       ├─🗁 php-fpm.d                 #       ├─🗁 php-fpm.d
       ├─📄 php-fpm.conf.default      #       ├─📄 php-fpm.conf.default
       └─📄 pear.conf                 #       └─📄 pear.conf
    └─🗁 ${includedir}                #    └─🗁 include
       └─🗁 php                       #       └─🗁 php
          ├─🗁 ext                    #          ├─🗁 ext
          ├─🗁 main                   #          ├─🗁 main
          ├─🗁 sapi                   #          ├─🗁 sapi
          ├─🗁 TSRM                   #          ├─🗁 TSRM
          └─🗁 Zend                   #          └─🗁 Zend
    └─🗁 ${libdir}                    #    └─🗁 lib
       └─🗁 php                       #       └─🗁 php
          ├─🗁 20230901-zts-debug     #          ├─🗁 20230901-zts-debug
          └─🗁 build                  #          └─🗁 build
    ├─🗁 ${sbindir}                   #    ├─🗁 sbin
    └─🗁 ${datarootdir}               #    └─🗁 share
       └─🗁 ${mandir}                 #       └─🗁 man
          ├─🗁 man1                   #          └─🗁 man1
          └─🗁 man8                   #          └─🗁 man8
       ├─🗁 pear                      #       └─🗁 pear
       └─🗁 php                       #       └─🗁 php
          └─🗁 fpm                    #            └─🗁 fpm
    └─🗁 ${localstatedir}             #    └─🗁 var
       └─🗁 log                       #       └─🗁 log
    └─🗁 ${runstatedir}               #    └─🗁 var/run
```

## Installing PHP with CMake

In this repository, installing PHP with CMake can be done in a similar way:

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

To adjust the installation locations, the
[GNUInstallDirs](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)
module is used to set additional `CMAKE_INSTALL_*` variables.

* `CMAKE_INSTALL_BINDIR` - name of the bin directory
* `CMAKE_INSTALL_DATADIR` - name of the etc directory
* `CMAKE_INSTALL_DATAROOTDIR` - name of the etc directory
* `CMAKE_INSTALL_INCLUDEDIR` - name of the include directory for headers
* `CMAKE_INSTALL_LIBDIR` - name of the directory containing libraries
* `CMAKE_INSTALL_LOCALSTATEDIR` - name of the var directory
* `CMAKE_INSTALL_MANDIR` - name of the man documentation directory
* `CMAKE_INSTALL_RUNSTATEDIR` - name of the run-time data directory (var/run)
* `CMAKE_INSTALL_SBINDIR` - name of the sbin directory
* `CMAKE_INSTALL_SYSCONFDIR` - name of the etc directory
* ...

These variables are by default relative paths. When customized, they can be
either relative or absolute. When changed to absolute values the installation
prefix will not be taken into account.

> [!TIP]
> To set the PHP include directory, there is also `PHP_INCLUDE_PREFIX` cache
> variable available, that can adjust the path inside the
> `CMAKE_INSTALL_INCLUDEDIR`.

### Installation directory structure

PHP installation directory structure when using CMake:

```sh
🗁 <DESTDIR>                          #
└─🗁 <CMAKE_INSTALL_PREFIX>           # 🗁 /usr/local (Windows: C:/Program Files/${PROJECT_NAME})
   ├─🗁 <CMAKE_INSTALL_BINDIR>        # ├─🗁 bin
   └─🗁 <CMAKE_INSTALL_SYSCONFDIR>    # └─🗁 etc
      ├─🗁 php-fpm.d                  #    ├─🗁 php-fpm.d
      ├─📄 php-fpm.conf.default       #    ├─📄 php-fpm.conf.default
      └─📄 pear.conf                  #    └─📄 pear.conf
   └─🗁 <CMAKE_INSTALL_INCLUDEDIR>    # └─🗁 include
      └─🗁 <PHP_INCLUDE_PREFIX>       #    └─🗁 php
         ├─🗁 ext                     #       ├─🗁 ext
         ├─🗁 main                    #       ├─🗁 main
         ├─🗁 sapi                    #       ├─🗁 sapi
         ├─🗁 TSRM                    #       ├─🗁 TSRM
         └─🗁 Zend                    #       └─🗁 Zend
   └─🗁 <CMAKE_INSTALL_LIBDIR>        # └─🗁 lib
      └─🗁 php                        #    └─🗁 php
         ├─🗁 20230901-zts-debug...   #       ├─🗁 20230901-zts-debug...
         └─🗁 build                   #       └─🗁 build
      └─🗁 pkgconfig                  #    └─🗁 pkgconfig
         ├─📄 php-embed.pc            #       ├─📄 php-embed.pc
         └─📄 php.pc                  #       └─📄 php.pc
   ├─🗁 <CMAKE_INSTALL_SBINDIR>       # ├─🗁 sbin
   └─🗁 <CMAKE_INSTALL_DATAROOTDIR>   # └─🗁 share
      └─🗁 <CMAKE_INSTALL_MANDIR>     #    └─🗁 man
         ├─🗁 man1                    #       ├─🗁 man1
         └─🗁 man8                    #       └─🗁 man8
   └─🗁 <CMAKE_INSTALL_DATADIR>       # └─🗁 (share)
      ├─🗁 pear                       #    ├─🗁 pear
      └─🗁 php                        #    └─🗁 php
         └─🗁 fpm                     #       └─🗁 fpm
   └─🗁 <CMAKE_INSTALL_LOCALSTATEDIR> # └─🗁 var
      └─🗁 log                        #    └─🗁 log
   └─🗁 <CMAKE_INSTALL_RUNSTATEDIR>   # └─🗁 var/run
```

> [!NOTE]
> The `DATAROOTDIR` and `DATADIR` are treated separately to be able to adjust
> only the `DATADIR` with project specific files, while leaving the
> `DATAROOTDIR` intact for man or other files. See also
> [GNU](https://www.gnu.org/prep/standards/html_node/Directory-Variables.html)
> explanation for more info.

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
      "installDir": "/install/prefix",
      "cacheVariables": {
        "CMAKE_INSTALL_BINDIR": "home/user/.local/bin",
        "PHP_BUILD_SYSTEM": "Acme Linux",
        "PHP_BUILD_PROVIDER": "Acme",
        "PHP_BUILD_COMPILER": "GCC",
        "PHP_BUILD_ARCH": "x86",
        "PHP_VERSION_LABEL": "-acme",
        "PHP_EXTENSION_DIR": "lib/php83/extensions"
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
