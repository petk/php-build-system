# Dependencies in C/C++ projects

Here is an overview of dependency management in C/C++ projects, including what
they are, why they are important, and various options for managing them in Git
projects.

## Index

* [1. Introduction to dependencies](#1-introduction-to-dependencies)
* [2. Why manage dependencies?](#2-why-manage-dependencies)
* [3. Options for managing dependencies](#3-options-for-managing-dependencies)
  * [3.1. Manual dependency management](#31-manual-dependency-management)
  * [3.2. Git submodules](#32-git-submodules)
  * [3.3. Conan](#33-conan)
  * [3.4. Vcpkg](#34-vcpkg)
  * [3.5. Chocolatey for Windows](#35-chocolatey-for-windows)
  * [3.6. Building dependencies from source](#36-building-dependencies-from-source)
  * [3.7. pkgconf](#37-pkgconf)
* [4. CMake](#4-cmake)
  * [4.1. find\_package](#41-find_package)
  * [4.2. FetchContent](#42-fetchcontent)
  * [4.3. CPM.cmake](#43-cpmcmake)
* [5. PHP dependencies](#5-php-dependencies)

## 1. Introduction to dependencies

Dependency management in C/C++ projects has, historically, presented a
significant challenge. While recent years have seen the emergence of some
package managers tailored to installing 3rd-party libraries, the C/C++ ecosystem
still lacks a unified, robust, and widely embraced standard akin to Composer or
other package managers. This shortfall primarily arises from the complex
landscape of diverse systems and architectural disparities within the C/C++
ecosystem.

In software development, dependencies refer to external libraries, frameworks,
or modules that your project relies on to function correctly. These dependencies
are often essential for various reasons, such as providing functionality, saving
development time, or reusing code.

## 2. Why manage dependencies?

Managing dependencies is crucial for several reasons:

* Version control: Different versions of dependencies may introduce bugs or
  incompatibilities. Proper management ensures project is using the right
  versions.

* Portability: C/C++ project may need to run on different platforms. Managing
  dependencies helps ensure consistent behavior across platforms.

* Collaboration: When working on a team, consistent and easily replicable
  dependencies streamline collaboration.

## 3. Options for managing dependencies

### 3.1. Manual dependency management

The simplest approach is manually downloading and including dependencies in
your project. This involves copying library files or source code into your
project directory. While straightforward, it can lead to version control issues
and is not recommended for large or complex projects. When the upstream library
changes, the source files need to be manually updated in the project.

### 3.2. Git submodules

[Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) allow you
to include other Git repositories within your own. This approach keeps
dependencies separate and tracks their versions.

To add a submodule:

```sh
git submodule add <repository_url> <path_to_submodule_directory>
```

However, when using Git submodules development experience is not very ideal.
When cloning a repository, additional option needs to be used:

```sh
git clone --recurse-submodules <repository_url>
```

Because Git submodules are tracked by Git, switching branches needs to be done a
bit carefully. Specially, if location of the submodule includes other files in
other branches.

### 3.3. Conan

[Conan](https://conan.io/) is a dedicated C/C++ package manager that simplifies
dependency management, including version control and binary packages. It allows
you to define dependencies in a `conanfile.txt` or `conanfile.py` and fetches
them from a central repository. Conan also supports creating and sharing
packages. It integrates with CMake and other build systems.

### 3.4. Vcpkg

[Vcpkg](https://vcpkg.io) provides precompiled libraries for various platforms
and integrates with CMake, Visual Studio, or can be used as a standalone tool.

### 3.5. Chocolatey for Windows

In Windows environments, Chocolatey has gained popularity as a package manager
that simplifies the installation and management of various software packages,
including C/C++ libraries, enhancing the dependency management experience for
Windows-based C/C++ projects.

### 3.6. Building dependencies from source

Sometimes, you may need to build dependencies from source. In this case, you can
create scripts or use build automation tools (like Make or CMake) to build and
include these dependencies as part of your project's build process.

### 3.7. pkgconf

[pkgconf](http://pkgconf.org/) is a tool for managing package dependencies in
Unix-based systems. It simplifies the process of locating and retrieving
information about installed libraries and their build flags, streamlining
development workflows.

`pkgconf` is more actively maintained standalone project similar and compatible
with the initial Freedesktop's
[pkg-config](https://gitlab.freedesktop.org/pkg-config/pkg-config).

PHP Autotools build system requires `pkgconf` to locate system dependencies.

Quick usage:

```sh
# List of all known package names on the system:
pkgconf --list-package-names

# Print required linker flags to stdout for given package name:
pkgconf --libs libcrypt

# Print the version of the queried module:
pkgconf --modversion libcrypt

# Pring CFLAGS:
pkgconf --cflags librypt

# See --help for further info:
pkgconf --help
```

The `pkgconf` ships with M4 macro file `pkg.m4` for Autotools-based build
systems.

Compiler and linker flags can be also overridden with `pkgconf` macro which
creates so called precious variables that can be used when calling configure
script (see `./configure --help`). For example, when certain library on system
is manually built on a different location and `pkgconf` cannot find it among the
installed system packages, these variables can help build system to find the
library:

```sh
./configure LIBZIP_LIBS=... LIBZIP_CFLAGS=... --with-zip
```

CMake has a
[FindPkgConfig](https://cmake.org/cmake/help/latest/module/FindPkgConfig.html)
module.

The information about system package is read from the `packagename.pc` file that
needs to be included in the root directory of the package source code. Some
C/C++ packages don't ship with such file, so `pkgconf` information is not
available for every system package out there.

## 4. CMake

CMake is not a dependency manager on its own but it can fetch, build, and link
libraries as part of project's build process.

### 4.1. find_package

The
[`find_package()`](https://cmake.org/cmake/help/latest/command/find_package.html)
is used to find external dependencies on the system. Either by manually written
`Find<PackageName>.cmake` modules in the project or if dependency ships with its
own CMake config package file. CMake has even some find modules built in.

```cmake
# Finding external dependency with version 1.2.3 or later.
find_package(ExternalDependency 1.2.3 REQUIRED)
```

The `REQUIRED` keyword will stop the CMake configuration step if dependency is
not found.

Dependency can be then linked to targets within the project:

```cmake
target_link_libraries(
  <target-name>
  INTERFACE|PUBLIC|PRIVATE ExternalDependency::Component
)
```

The `FeatureSummary` CMake module can add metadata to package.

```cmake
# FindPackageName.cmake

include(FeatureSummary)

set_package_properties(PackageName PROPERTIES
  URL "https://example.com/"
  DESCRIPTION "Package library"
)
```

Using the package property type `REQUIRED` and
`FATAL_ON_MISSING_REQUIRED_PACKAGES` option at `feature_summary` enables listing
all required missing packages at the end of the configuration step.

```cmake
find_package(PackageName)
set_package_properties(PackageName PROPERTIES
  TYPE REQUIRED
)

# If PackageName was not found, configuration step will stop here:
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
```

### 4.2. FetchContent

[FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) can
be used for "simpler" dependencies. With `FetchContent`, the dependency can be a
separate Git repository, can be downloaded at the build time, and then built
together with the entire project.

```cmake
FetchContent_Declare(
  library
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        703bd9caab50b139428cea1aaff9974ebee5742e # release-1.10.0
)
```

### 4.3. CPM.cmake

[CPM.cmake](https://github.com/cpm-cmake/CPM.cmake) is a cross-platform script
that can download and manage dependencies. Under the hood it uses
`FetchContent`.

```cmake
include(cmake/CPM.cmake)

CPMAddPackage("gh:fmtlib/fmt#7.1.3")
```

## 5. PHP dependencies

A list of various dependencies needed to build PHP from source:

* libxml for the ext/libxml, ext/dom, ext/simplexml, ext/xml, ext/xmlwriter, and
  ext/xmlreader extensions
* sqlite3 for the ext/sqlite3 and ext/pdo_sqlite extensions
* libcapstone (for the OPcache `--with-capstone` option)
* libssl (for OpenSSL `--with-openssl`)
* libkrb5 (for the OpenSSL `--with-kerberos` option)
* libaspell and libpspell (for the ext/pspell `--with-pspell` option)
* zlib
  * when using `--enable-gd` with bundled libgd
  * when using `--with-zlib`
  * when using `--with-pdo-mysql` or `--with-mysqli` (option
    `--enable-mysqlnd-compression-support` needs it)
* libpng
  * when using `--enable-gd` with bundled libgd
* libavif
  * when using `--enable-gd` with bundled libgd and `--with-avif` option.
* libwebp
  * when using `--enable-gd` with bundled libgd and `--with-webp` option.
* libjpeg
  * when using `--enable-gd` with bundled libgd and `--with-jpeg` option.
* libxpm
  * when using `--enable-gd` with bundled libgd and `--with-xpm` option.
* libfretype
  * when using `--enable-gd` with bundled libgd and `--with-freetype` option.
* libgd
  * when using `--enable-gd` with external libgd `--with-external-gd`.
* libonig
  * when using `--enable-mbstring`
* libtidy
  * when using `--with-tidy`
* libxslt
  * when using `--with-xsl`
* libzip
  * when using `--with-zip`
* libargon2
  * when using `--with-password-argon2`
* libedit
  * when using `--with-libedit`
* libreadline
  * when using `--with-readline`
* libsnmp
  * when using `--with-snmp`
* libexpat1
  * when using the `--with-expat`
* libacl
  * when using the `--with-fpm-acl`
* libapparmor
  * when using the `--with-fpm-apparmor`
* libselinux1
  * when using the `--with-fpm-selinux`
* libsystemd
  * when using the `--with-fpm-systemd`
* libldap2
  * when using the `--with-ldap`
* libsasl2
  * when using the `--with-ldap-sasl`
* libpq
  * when using the `--with-pgsql` or `--with-pdo-pgsql`
* libmm
  * when using the `--with-mm`
* libdmalloc
  * when using the `--enable-dmalloc`
* freetds
  * when using the `--enable-pdo-dblib`
* libcdb
  * when using the `--with-cdb=DIR`
* liblmdb
  * when using the `--with-lmdb`
* libtokyocabinet
  * when using the `--with-tcadb`
* libgdbm
  * when using the `--with-gdbm`
* libqdbm
  * when using the `--with-qdbm`
* libgdbm or library implementing the ndbm or dbm compatibility interface
  * when using the `--with-dbm` or `--with-ndbm`
* libdb
  * when using the `--with-db4`, `--with-db3`, `--with-db2`, or `--with-db1`
