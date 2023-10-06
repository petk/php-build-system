# Dependencies in C/C++ projects

Here is an overview of dependency management in C/C++ projects, including what
they are, why they are important, and various options for managing them in Git
projects.

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

# See --help for further info:
pkgconf --help
```

The `pkgconf` ships with M4 macro file `pkg.m4` for Autotools based build
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

Most of the time,
[`find_package()`](https://cmake.org/cmake/help/latest/command/find_package.html)
is used to find project dependencies on the system. Either by manually written
`Find<PackageName>.cmake` modules in the project or if dependency ships with
its own CMake config package file. CMake has also some find modules built in.

```cmake
find_package(OpenSSL)
target_link_libraries(php PRIVATE OpenSSL::SSL)
```

[FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) can
be used for "simpler" dependencies. With `FetchContent`, the dependency can be a
separate Git repository, can be downloaded at the build time, and then built
together with the entire project.
