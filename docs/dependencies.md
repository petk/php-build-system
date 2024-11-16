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
  * [3.7. pkgconf/pkg-config](#37-pkgconfpkg-config)
* [4. CMake](#4-cmake)
  * [4.1. find\_package](#41-find_package)
    * [4.1.1. Find module example](#411-find-module-example)
    * [4.1.2. How to override CMake find module](#412-how-to-override-cmake-find-module)
  * [4.2. FetchContent](#42-fetchcontent)
  * [4.3. CPM.cmake](#43-cpmcmake)
* [5. Common Package Specification (CPS)](#5-common-package-specification-cps)
* [6. PHP dependencies](#6-php-dependencies)

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

### 3.7. pkgconf/pkg-config

[pkgconf](http://pkgconf.org/) is a tool for managing package dependencies in
Unix-based systems. It simplifies the process of locating and retrieving
information about installed libraries and their build flags, streamlining
development workflows.

`pkgconf` is more actively maintained standalone project similar and compatible
with the initial Freedesktop's
[pkg-config](https://gitlab.freedesktop.org/pkg-config/pkg-config). Systems
usually provide both `pkgconf` and `pkg-config` as a symbolic link on the
command line.

PHP Autotools build system requires `pkgconf` to locate some system
dependencies.

Quick usage:

```sh
# List of all known packages on the system:
pkgconf --list-all

# Print required linker flags to stdout for given package name:
pkgconf --libs libcrypt

# Print the version of the queried module:
pkgconf --modversion libcrypt

# Print CFLAGS:
pkgconf --cflags libcrypt

# See --help for further info:
pkgconf --help

# Pass additional .pc file(s):
PKG_CONFIG_PATH=/path/to/pkgconfig pkgconf --modversion libcrypt
```

The `pkgconf` ships with Autoconf M4 macro file `pkg.m4` for Autotools-based
build systems and provides several macros, such as `PKG_CHECK_MODULES`.

`PKG_CHECK_MODULES` creates so-called precious variables `*_LIBS` and `*_CFLAGS`
for using dependency in the build system. See `./configure --help` for all the
available variables. These compiler and linker flags can be also overridden. For
example, when developing, or when dependency is manually installed to a custom
location and `pkgconf` cannot find it among the system packages.

```sh
# When using custom libzip installation:
./configure LIBZIP_LIBS="-L/path/to/libzip/lib -lzip" \
            LIBZIP_CFLAGS="-I/path/to/libzip/include" \
            --with-zip
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

set_package_properties(
  PackageName
  PROPERTIES
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

#### 4.1.1. Find module example

Example of a `FindFoo.cmake` module:

```cmake
#[=============================================================================[
Find the Foo package.

Module defines the following IMPORTED target(s):

  Foo::Foo
    The package library, if found.

Result variables:

  Foo_FOUND
    Whether the package has been found.
  Foo_INCLUDE_DIRS
    Include directories needed to use this package.
  Foo_LIBRARIES
    Libraries needed to link to the package library.
  Foo_VERSION
    Package version, if found.

Cache variables:

  Foo_INCLUDE_DIR
    Directory containing package library headers.
  Foo_LIBRARY
    The path to the package library.

Hints:

  The Foo_ROOT variable adds custom search path.
#]=============================================================================]

include(FeatureSummary)
include(FindPackageHandleStandardArgs)

set_package_properties(
  Foo
  PROPERTIES
    URL "https://example.com"
    DESCRIPTION "Foo package example"
)

set(_reason "")

# Use pkgconf, if available on the system.
find_package(PkgConfig QUIET)
pkg_check_modules(PC_Foo QUIET libfoo)

find_path(
  Foo_INCLUDE_DIR
  NAMES foo.h
  PATHS ${PC_Foo_INCLUDE_DIRS}
  DOC "Directory containing Foo library headers"
)

if(NOT Foo_INCLUDE_DIR)
  string(APPEND _reason "foo.h not found. ")
endif()

find_library(
  Foo_LIBRARY
  NAMES foo
  PATHS ${PC_Foo_LIBRARY_DIRS}
  DOC "The path to the Foo library"
)

if(NOT Foo_LIBRARY)
  string(APPEND _reason "Foo library not found. ")
endif()

# Get version.
block(PROPAGATE Foo_VERSION)
  # Try finding version from the library header file.
  # ...

  # If library doesn't have version in headers, try pkgconf version, if found.
  if(NOT Foo_VERSION AND PC_Foo_VERSION)
    # Check if result found by find_library() and pkgconf are the same library.
    cmake_path(COMPARE "${PC_Foo_INCLUDEDIR}" EQUAL "${Foo_INCLUDE_DIR}" isEqual)

    if(isEqual)
      set(Foo_VERSION ${PC_Foo_VERSION})
    endif()
  endif()

  if(NOT Foo_VERSION)
    # Use different ways to find package version, when pkgconf is not available.
    # ...
  endif()
endblock()

mark_as_advanced(Foo_INCLUDE_DIR Foo_LIBRARY)

find_package_handle_standard_args(
  Foo
  REQUIRED_VARS
    Foo_LIBRARY
    Foo_INCLUDE_DIR
  VERSION_VAR Foo_VERSION
  REASON_FAILURE_MESSAGE "${_reason}"
)

unset(_reason)

if(NOT Foo_FOUND)
  return()
endif()

set(Foo_INCLUDE_DIRS ${Foo_INCLUDE_DIR})
set(Foo_LIBRARIES ${Foo_LIBRARY})

if(NOT TARGET Foo::Foo)
  add_library(Foo::Foo UNKNOWN IMPORTED)

  set_target_properties(
    Foo::Foo
    PROPERTIES
      IMPORTED_LOCATION "${Foo_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${Foo_INCLUDE_DIR}"
  )
endif()
```

#### 4.1.2. How to override CMake find module

CMake by default includes many find modules. If a case is encountered where the
default CMake find module doesn't suffice for the project usage, this is one of
the approaches that can be taken.

The `CMakeLists.txt` example:

```cmake
# CMakeLists.txt

cmake_minimum_required(VERSION 3.25)

# Append project local CMake modules.
list(APPEND CMAKE_MODULE_PATH "cmake/modules")

project(PHP)

find_package(Iconv)
```

Create a module with the same name in your local project CMake modules
directory. For example:

```cmake
# cmake/modules/FindIconv.cmake

# Here, find module can be customized before including the upstream module. For
# example, adding search paths, changing initial values of the find module,
# adding pkgconf/pkg-config functionality, and similar.

# Find package with upstream CMake module; override CMAKE_MODULE_PATH to prevent
# the maximum nesting/recursion depth error on some systems, like macOS.
set(_php_cmake_module_path ${CMAKE_MODULE_PATH})
unset(CMAKE_MODULE_PATH)
include(FindIconv)
set(CMAKE_MODULE_PATH ${_php_cmake_module_path})
unset(_php_cmake_module_path)

# Here, find module can be customized after including the upstream module. For
# example, adding new result variables.
```

With this, when calling the find_package(Iconv), the local FindIconv module will
be used and the upstream CMake module will be included in it, making it possible
to adjust code before and after the inclusion.

Instead of calling `find_package()` inside a find module, the `include()` can be
used and `CMAKE_MODULE_PATH` disabled. Otherwise, on some systems the maximum
nesting/recursion depth error occurs because CMake will try to include the
local FindIconv recursively.

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

## 5. Common Package Specification (CPS)

The [Common Package Specification](https://cps-org.github.io/cps/) is a new
approach to specify package metadata using a JSON Schema file.

## 6. PHP dependencies

A list of various dependencies needed to build PHP from source:

* libxml for the ext/libxml, ext/dom, ext/simplexml, ext/xml, ext/xmlwriter, and
  ext/xmlreader extensions
* sqlite3 for the ext/sqlite3 and ext/pdo_sqlite extensions
* libcapstone (for the OPcache `--with-capstone` option)
* libssl (for OpenSSL `--with-openssl`)
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
* libqdbm
  * when using the `--with-qdbm`
* library implementing the ndbm or dbm compatibility interface
  * when using the `--with-dbm` or `--with-ndbm`
* libdb
  * when using the `--with-db4`, `--with-db3`, `--with-db2`, or `--with-db1`
