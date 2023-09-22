#!/bin/sh
#
# Helper that displays diff of the main/php_config.h.in file for comparing it
# with CMake's one.

# PHP configuration header file.
filename="php_config.h.in"
branch="PHP-8.3"

# Patterns of unused defines to remove from the configuration header file. One
# line above and after the pattern will be also removed.
patterns="
#undef\sHAVE_DLSYM
#undef\sHAVE_DLOPEN
#undef\sPTHREADS
#undef\sHAVE_LIBATOMIC
#undef\sHAVE___ATOMIC_EXCHANGE_1
#undef\sHAVE_LIBM
#undef\sHAVE_LIBRT
#undef\sHAVE_HTONL
#undef\sHAVE_INTMAX_T
#undef\sHAVE_SSIZE_T
#undef\sHAVE_STDIO_H
#undef\sHAVE_STDLIB_H
#undef\sHAVE_DECL_STRERROR_R
#undef\sZEND_FIBER_ASM
#undef\sHAVE_MYSQL
#undef\sHAVE_LIBPQ
"

# Similar to the above patterns except the two lines above and one after the
# pattern will be also removed.
patterns_2="
#undef\sHAVE_ST_BLOCKS
#undef\sHAVE_TM_ZONE
"

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

while test $# -gt 0; do
  if test "$1" = "-h" || test "$1" = "--help"; then
    cat << HELP
Helper that displays diff of the main/php_config.h.in file for comparing it with
CMake's one. It additionally removes some redundant constants.

SYNOPSIS:
  php-config.sh [<options>]

OPTIONS:
  -b, --branch VALUE     PHP branch to checkout. Defaults to PHP-8.3.
  -h, --help             Display this help.
HELP
    exit 0
  fi

  if test "$1" = "-b" || test "$1" = "--branch"; then
    branch=$2
    shift
  fi

  shift
done

# Clone a fresh latest php-src repo.
if test ! -d "php-src"; then
  git clone --depth 1 https://github.com/php/php-src ./php-src
fi

cd php-src

# Check if given branch is available.
git fetch origin ${branch}:${branch}
if test -z "$(git show-ref refs/heads/${branch})"; then
  echo "Branch ${branch} is missing." >&2
  exit 1
fi

# Reset php-src repository and fetch latest changes.
git reset --hard
git clean -dffx
git checkout ${branch}
git pull --rebase

# Create main/php_config.h.in.
./buildconf

cd ..

cp php-src/main/$filename $filename

# Remove patterns with one line above and one line below them.
for pattern in $patterns; do
  echo "Removing pattern $pattern"
  line=$(sed -n "/$pattern$/=" "$filename")
  previous_line=$((line - 1))
  next_line=$((line + 1))
  lines="${previous_line}d;${line}d;${next_line}d"
  sed -i "${lines}" "$filename"
done

# Remove patterns with two lines above and one line below them.
for pattern in $patterns_2; do
  echo "Removing pattern $pattern"
  line=$(sed -n "/$pattern$/=" "$filename")
  previous_line_1=$((line - 1))
  previous_line_2=$((line - 2))
  next_line=$((line + 1))
  lines="${previous_line_2}d;${previous_line_1}d;${line}d;${next_line}d"
  sed -i "${lines}" "$filename"
done

echo "\n${filename} diff:"

diff --color php-src/main/$filename $filename

rm $filename
