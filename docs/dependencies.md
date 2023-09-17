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
  * [3.5. CMake](#35-cmake)
  * [3.6. Building dependencies from source](#36-building-dependencies-from-source)
  * [3.7. Chocolatey for Windows](#37-chocolatey-for-windows)
  * [3.8. pkgconf](#38-pkgconf)

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
and is not recommended for large or complex projects.

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
bit carefully. Specially, if location of the submodule included other files in
other branches.

### 3.3. Conan

Conan is a dedicated C/C++ package manager that simplifies dependency
management, including version control and binary packages. It allows you to
define dependencies in a `conanfile.txt` or `conanfile.py` and fetches them from
a central repository. Conan also supports creating and sharing packages.

### 3.4. Vcpkg

[Vcpkg](https://vcpkg.io) provides precompiled libraries for various platforms
and integrates with CMake, Visual Studio, or can be used as a standalone tool.

### 3.5. CMake

CMake can fetch, build, and link libraries as part of project's build process.
It works well with many C/C++ libraries.

[FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html) can
be used for "simpler" dependencies.

With `FetchContent`, the dependency can be a separate Git repository, can be
downloaded at the build time, and then built together with the entire project.

### 3.6. Building dependencies from source

Sometimes, you may need to build dependencies from source. In this case, you can
create scripts or use build automation tools (like Make or CMake) to build and
include these dependencies as part of your project's build process.

### 3.7. Chocolatey for Windows

In Windows environments, Chocolatey has gained popularity as a package manager
that simplifies the installation and management of various software packages,
including C/C++ libraries, enhancing the dependency management experience for
Windows-based C/C++ projects.

### 3.8. pkgconf

`pkgconf`, also known as `pkg-config`, is a tool for managing package
dependencies in Unix-based systems. It simplifies the process of locating and
retrieving information about installed libraries and their build flags,
streamlining development workflows.
