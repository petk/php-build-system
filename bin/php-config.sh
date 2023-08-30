#!/bin/sh
#
# Helper that displays diff of the main/php_config.h.in file for comparing it
# with CMake's one.

# PHP configuration header file.
filename="php_config.h.in"

# Patterns of unused defines to remove from the configuration header file. One
# line above and after the pattern will be also removed.
patterns="
#undef\sHAVE_DLSYM
#undef\sHAVE_DLOPEN
#undef\sPTHREADS
#undef\sHAVE_LIBATOMIC
#undef\sHAVE___ATOMIC_EXCHANGE_1
"

# Go to project root.
cd $(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)

# Clone a fresh latest php-src repo.
if test ! -d "php-src"; then
  git clone --depth 1 https://github.com/php/php-src ./php-src
fi

cd php-src

# Fetch latest php-src repository changes.
git checkout .
git clean -dffx .
git pull --rebase

# Create main/php_config.h.in.
./buildconf

cd ..

cp php-src/main/$filename $filename

# Remove patterns with one line above and one line below them.
for pattern in $patterns; do
  echo "Removing pattern $pattern"
  line=$(sed -n "/$pattern/=" "$filename")
  previous_line=$((line - 1))
  next_line=$((line + 1))
  lines="${previous_line}d;${line}d;${next_line}d"
  sed -i "${lines}" "$filename"
done

echo "\n${filename} diff:"

diff --color php-src/main/$filename $filename

rm $filename
