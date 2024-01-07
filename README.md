# PHP build system

[![PHP version](https://img.shields.io/badge/PHP-8.3-777BB4?logo=php&labelColor=17181B)](https://www.php.net/)
[![CMake version](https://img.shields.io/badge/CMake-3.25-064F8C?logo=cmake&labelColor=17181B)](https://cmake.org)
[![C99](https://img.shields.io/badge/standard-C99-A8B9CC?logo=C&labelColor=17181B)](https://port70.net/~nsz/c/c99/n1256.html)
[![GNU](https://img.shields.io/badge/-GNU-A42E2B?logo=gnu&labelColor=17181B)](https://www.gnu.org/)
[![Ninja](https://img.shields.io/badge/%F0%9F%A5%B7-Ninja%20build-DD6620?labelColor=17181B)](https://ninja-build.org/)

> [!IMPORTANT]
> You are browsing the `PHP-8.3` branch of this repository. For the latest
> sources and documentation checkout the `master` branch.

## Quick usage - TL;DR

```sh
# Prerequisites for Debian-based distributions:
sudo apt install cmake gcc g++ bison re2c libxml2-dev libsqlite3-dev

# Prerequisites for Fedora-based distributions:
sudo dnf install cmake gcc gcc-c++ bison re2c libxml2-devel sqlite-devel

# Prerequisites for BSD-based systems:
sudo pkg install cmake bison re2c libxml2 sqlite3

# Clone this repository:
git clone https://github.com/petk/php-build-system

# Download latest PHP and add CMake files:
cmake -P php-build-system/bin/php.cmake 8.3-dev

# Generate build system from sources to a new build directory:
cmake -S php-build-system/php-8.3-dev -B my-php-build

# Build PHP in parallel:
cmake --build my-php-build -j

./my-php-build/sapi/cli/php -v
```
