# PHP installation

Installation of built files is a simple copy to a predefined directory structure
of given system. In this phase the executable binary files, dynamic library
objects, header files, \*nix man documentation pages, and similar files are
copied to system directories.

Please note that PHP installation on \*nix systems is typically handled by
system package managers through automated scripts. Additionally, it is common
practice to apply additional patches to tailor the PHP package to suit the
specific requirements of the \*nix distribution in use.

**Before running the `make install` or `cmake --install` command, be aware that
files will be copied outside of your current build directory.**

## Installing PHP with default Autotools

The default way to install PHP using Autotools across the system directories can
be done like this:

```sh
# Build configure script:
./buildconf

# Configure PHP build:
./configure --prefix=/install/path/prefix

# Build PHP with enabled multithreading:
make -j$(nproc)

# Run tests with enabled multithreading:
make TEST_PHP_ARGS=-j$(nproc) test

# Finally, copy built files to their system locations:
make INSTALL_ROOT="/install/path/prefix" install
```

Above, either the optional `--prefix` configure option, or the `INSTALL_ROOT`
environment variable can prefix the locations where the files will be copied. By
default the `--prefix` is set to `/usr/local` and `INSTALL_ROOT` is empty.

The `INSTALL_ROOT` variable name is customized for PHP and software from the
early Autotools days. Automake uses a more common variable name
[`DESTDIR`](https://www.gnu.org/software/automake/manual/html_node/DESTDIR.html),
however for historical reasons and since PHP doesn't use Automake, the
`INSTALL_ROOT` variable name is used in PHP instead.

The files are then copied to a predefined directory structure (GNU or PHP
style). The optional PHP Autotools configuration option
`--with-layout=[GNU|PHP]` defines the installation directory structure. By
default it is set to PHP style directory structure:

```sh
/install/path/prefix/
 └─ usr/
    └─ local/
       ├─ bin/                      # Executable binary directory
       └─ etc/                      # System configuration directory
          ├─ php-fpm.d/             # PHP FPM configuration directory
          └─ php-fpm.conf.default   # PHP FPM configuration
       └─ include/
          └─ php/                   # PHP headers
             ├─ ext/                # PHP extensions header files
             ├─ main/               # PHP main binding header files
             ├─ sapi/               # PHP SAPI header files
             ├─ TSRM/               # PHP TSRM header files
             └─ Zend/               # Zend engine header files
       └─ lib/
          └─ php/                   # PHP shared libraries and other build files
             ├─ build/              # Various PHP development and build files
             └─ extensions/
                └─ no-debug-non-zts-20230831/ # PHP shared extensions (*.so files)
       └─ php/
          └─ man/
             ├─ man1/               # PHP man section 1 pages for *nix systems
             └─ man8/               # PHP man section 8 pages for *nix systems
          └─ php/
             └─ fpm/                # Additional FPM static HTML files
       ├─ sbin/                     # Executable binaries for root priviledges
       └─ var/                      # The Linux var directory
          ├─ log/                   # Directory for PHP logs
          └─ run/                   # Runtime data directory
```

This is how the GNU layout directory structure looks like (`--with-layout=GNU`):

```sh
/install/path/prefix/
 └─ usr/
    └─ local/
       ├─ bin/
       └─ etc/
          ├─ php-fpm.d/
          └─ php-fpm.conf.default
       └─ include/
          └─ php/
             ├─ ext/
             ├─ main/
             ├─ sapi/
             ├─ TSRM/
             └─ Zend/
       └─ lib/
          └─ php/
             ├─ 20230831/         # PHP shared extensions (*.so files)
             └─ build/
       ├─ sbin/
       └─ share/                  # Directory with shareable files
          └─ man/
             ├─ man1/
             └─ man8/
          └─ php/
             └─ fpm/
       └─ var/
          ├─ log/
          └─ run/
```

Notice the difference of the shared extensions and the share directory.

Directory locations can be adjusted with several Autoconf default options:

* `--bindir=DIR` - to set the user executables location
* `--sbindir=DIR` - to set the root executables location
* `--includedir=DIR` - to set the C header files location
* `--libdir=DIR` - set the library location
* `--mandir=DIR` - set the man documentation location
* `--localstatedir=DIR` - set the var location
* `--runstatedir=DIR` - set the run location
* `--sysconfdir=DIR` - set the etc location
* ...

When packaging the PHP built files for certain system, additional environment
variables can help customize the installation locations and PHP package
information:

* `EXTENSION_DIR` - absolute path that overrides path to extensions shared
  objects (`.so` files). By default it is set to
  `/usr/local/lib/php/extensions/no-debug-non-zts-2023.../` or
  `/usr/local/lib/php/2023.../`.

Common practice is to also add program prefixes and suffixes (`php83`):

* `--program-prefix=PREFIX` - prepends built binaries with given prefix.
* `--program-suffix=SUFFIX` - appends suffix to binaries.

```sh
./configure \
  PHP_BUILD_SYSTEM="Acme Linux" \
  PHP_BUILD_PROVIDER="Acme" \
  PHP_BUILD_COMPILER="GCC" \
  PHP_BUILD_ARCH="x86" \
  PHP_EXTRA_VERSION="-acme" \
  EXTENSION_DIR=/path/to/php/extensions \
  --with-layout=GNU \
  --localstatedir=/var \
  --program-suffix=83 \
  # ...
```

See `./configure --help` for more information on how to adjust these locations.

## Installing PHP with CMake

In this repository, installing PHP with CMake can be done in a similar way:

```sh
# Configuration and generation of build system files:
cmake -DCMAKE_INSTALL_PREFIX="/install/path/prefix" .

# Build PHP with enabled multithreading:
cmake --build . -- -j $(nproc)

# Run tests using ctest utility:
ctest --progress -V

# Finally, copy built files to their system locations:
cmake --install

# Or
cmake .
cmake --build .
ctest --progress -V
cmake --install . --prefix "/install/path/prefix"
```

To adjust the installation locations, the
[GNUInstallDirs](https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html)
is used in the root `CMakeLists.txt` file which sets some additional
`CMAKE_INSTALL_*` variables.

* `CMAKE_INSTALL_BINDIR` - name of the bin directory.
* `CMAKE_INSTALL_SBINDIR` - name of the sbin directory.
* `CMAKE_INSTALL_SYSCONFDIR` - name of the etc directory.
* `CMAKE_INSTALL_LOCALSTATEDIR` - name of the var directory.
* ...

These variables are by default all relative path names. When customized, they
can be either relative or absolute. When changed to absolute values the
installation prefix will not be taken into account.

Instead of setting the `CMAKE_INSTALL_PREFIX` variable at the configuration
phase, or using the `--prefix` installation option, there is also `installDir`
option which can be set in the `CMakePresets.json` or `CMakeUserPresets.json`
file.

Example `CMakeUserPresets.json` file, which can be added to the PHP source code
root directory:

```json
{
  "version": 3,
  "configurePresets": [
    {
      "name": "acme-php",
      "inherits": "unix-full",
      "displayName": "Acme PHP configuration",
      "description": "Customized PHP build",
      "installDir": "/install/path/prefix",
      "cacheVariables": {
        "CMAKE_INSTALL_BINDIR": "home/user/.local/bin",
        "PHP_BUILD_SYSTEM": "Acme Linux",
        "PHP_BUILD_PROVIDER": "Acme",
        "PHP_BUILD_COMPILER": "GCC",
        "PHP_BUILD_ARCH": "x86",
        "PHP_VERSION_LABEL": "-acme",
        "PHP_EXTENSION_DIR": "/install/path/prefix/lib/php83/extensions"
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

Above file *inherits* from the `unix-full` configuration preset of the root
default `CMakePresets.json` file and adjusts the PHP installation.

To build and install using the new preset:

```sh
cmake --preset acme-php
cmake --build --preset acme-php -- -j $(nproc)
ctest --preset acme-php
cmake --install .
```
