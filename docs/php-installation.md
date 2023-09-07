# PHP installation

Installation of built files is a simple copy to a predefined directory structure
of given system. In this phase the executable binary files, dynamic library
objects, header files, *nix man pages, and similar files are copied to system
directories.

Please note that PHP installation on *nix systems is typically handled by system
package managers through automated scripts. Additionally, it is common practice
to apply additional patches to tailor the PHP package from the repository to
suit the specific requirements of the *nix distribution in use.

**Before running the `make install` command, be aware that files will be copied
outside of your current build directory.**

## Installing PHP with default Autotools

The default way to install PHP using Autotools after the build steps across the
\*nix system directories is done like this:

```sh
# Build configure script:
./buildconf

# Configure PHP build:
./configure

# Build PHP with enabled multithreading:
make -j$(nproc)

# Run tests with enabled multithreading:
make TEST_PHP_ARGS=-j$(nproc) test

# Finally, copy built files to their system locations.
make INSTALL_ROOT="/install/path/prefix" install
```

Above, the optional `INSTALL_ROOT` environment variable can prefix the locations
where the files will be copied. The name is customized for PHP and software from
the early Autotools days. In Automake, a pracitce is otherwise to use the
variable [`DESTDIR`](https://www.gnu.org/software/automake/manual/html_node/DESTDIR.html),
however for historical reasons and since PHP doesn't use Automake, the
`INSTALL_ROOT` variable name is used in PHP instead.

The files are then copied to a predefined directory structure (GNU or PHP
style):

```sh
/install/path/prefix/
 ├─ bin/                      # Executable binary directory
 └─ include/
    └─ php/                   # PHP headers
       ├─ ext/                # PHP extensions header files
       ├─ main/               # PHP main binding header files
       ├─ sapi/               # PHP SAPI header files
       ├─ TSRM/               # PHP thread safe resource manager header files
       └─ Zend/               # Zend engine header files
 └─ lib/
    └─ php/                   # PHP shared libraries and other build files
       ├─ build/              # Various PHP development scripts and build files
       └─ extensions/
          └─ {EXTENSION_DIR}/ # PHP shared extensions (*.so files)
 └─ php/
    └─ man/
       └─ man1/               # PHP man section 1 pages for *nix systems
 └─ var/                      # The Linux var directory
    ├─ log/                   # Directory for PHP logs
    └─ run/                   # Runtime data directory
```

The optional PHP `--with-layout=[GNU|PHP]` Autotools configuration option
defines the directory structure. By default it is set to PHP style directory
structure.

```sh
/install/path/prefix/
 └─ usr/
    └─ local/
       ├─ bin/                   # Executable binary directory
       └─ include/
          └─ php/                # PHP headers
             ├─ ext/             # PHP extensions header files
             ├─ main/            # PHP main binding header files
             ├─ sapi/            # PHP SAPI header files
             ├─ TSRM/            # PHP thread safe resource manager header files
             └─ Zend/            # Zend engine header files
       └─ lib/
          └─ php/                # PHP shared libraries and other build files
             ├─ build/           # Various PHP development scripts and build files
             └─ {EXTENSION_DIR}/ # PHP shared extensions (*.so files)
       └─ share/
          └─ man/
             └─ man1/            # PHP man section 1 pages for *nix systems
       └─ var/                   # The Linux var directory
          ├─ log/                # Directory for PHP logs
          └─ run/                # Runtime data directory
```

Directory locations can be adjusted with several Autoconf default options:

* `--bindir=DIR` - to set the user executables location
* `--includedir=DIR` - to set the C header files location
* `--libdir=DIR` - set the library location
* `--mandir=DIR` - set the man documentation location
* `--localstatedir=DIR` - set the var location
* `--runstatedir=DIR` - set the run location
* ...

When packaging the PHP built files for certain *nix system, many times some
additional environment variables help customize the installation locations and
PHP package information:

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
  # ...
```

See `./configure --help` for more information on how to adjust these locations.

## Installing PHP with CMake

In this repository, installing PHP with CMake can be done in a similar way:

```sh
# Configuration
cmake -DCMAKE_INSTALL_PREFIX="/install/path/prefix" .
# Build
cmake --build .
# Tests
ctest
# Installation
cmake --install

# Or
cmake .
cmake --build .
ctest
cmake --install . --prefix "/install/path/prefix"
```

Instead of setting the `CMAKE_INSTALL_PREFIX` variable at the configuration
phase, or using the `--prefix` installation option, there is also `installDir`
option which can be set in the `CMakePresets.json` or `CMakeUserPresets.json`
file.

```json
{
  "version": 3,
  "configurePresets": [
    {
      "name": "default",
      "installDir": "/install/path/prefix",
      "cacheVariables": {
        "PHP_BUILD_SYSTEM": "Acme Linux",
        "PHP_BUILD_PROVIDER": "Acme",
        "PHP_BUILD_COMPILER": "GCC",
        "PHP_EXTRA_VERSION": "-acme",
        "PHP_BUILD_ARCH": "x86",
        "PHP_EXTRA_VERSION": "-acme",
        "PHP_EXTENSION_DIR": "/path/to/php/extensions"
      }
    }
  ]
}
```
