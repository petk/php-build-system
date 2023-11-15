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
#undef\sZEND_FIBER_ASM
#undef\sHAVE_MYSQL
#undef\sHAVE_LIBPQ
#undef\sHAVE_TIMER_CREATE
#undef\sHAVE_SYS_SDT_H
#undef\sDBA_CDB_MAKE
#undef\sHAVE_NETINET_TCP_H
#undef\sHAVE_SYS_UN_H
#undef\sHAVE_CREATEPROCESS
#undef\sHAVE_LIBRESOLV
#undef\sHAVE_LIBBIND
#undef\sHAVE_LIBSOCKET
#undef\sHAVE_LIBROOT
#undef\sHAVE_LIBNETWORK
#undef\sHAVE_LIBNSL
#undef\sHAVE_LIBUTIL
#undef\sHAVE_LIBBSD
#undef\sHAVE_LIBCRYPT
#undef\sHAVE_LIBPAM
#undef\sHAVE_DECL_TZNAME
#undef\sHAVE_IMAP2000
#undef\sHAVE_IMAP
#undef\sHAVE_IMAP2001
#undef\sHAVE_IMAP2004
#undef\sHAVE_IMAP_KRB
#undef\sHAVE_IMAP_AUTH_GSS
#undef\sHAVE_IMAP_MUTF7
#undef\sHAVE_IMAP_SSL
#undef\sCOMPILE_DL_IMAP
#undef\sHAVE_SOCKET
#undef\sPACKAGE_BUGREPORT
#undef\sPACKAGE_NAME
#undef\sPACKAGE_STRING
#undef\sPACKAGE_TARNAME
#undef\sPACKAGE_URL
#undef\sPACKAGE_VERSION
#undef\sHAVE_SHM_OPEN
"

# Similar to the above patterns except the two lines above and one after the
# pattern will be also removed.
patterns_2="
#undef\sHAVE_DECL_STRERROR_R
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

# Clone a fresh latest php-src repository.
if test ! -d "php-src"; then
  echo "To use this tool you need php-src Git repository."
  printf "Do you want to clone it now (y/N)?"
  read answer

  if test "$answer" != "${answer#[Yy]}"; then
    echo "Cloning github.com/php/php-src. This will take a little while."
    git clone https://github.com/php/php-src ./php-src
  else
    exit 1
  fi
fi

# Make sure we're in the php-src respository.
cd php-src

if test ! -f "main/php_version.h" \
  || test ! -f "php.ini-development"
then
  echo "Git repository doesn't seem to be php-src." >&2
  exit 1
fi

# Check if given branch is available.
if test -z "$(git show-ref refs/heads/${branch})"; then
  if test -z "$(git ls-remote --heads origin refs/heads/${branch})"; then
    echo "Branch ${branch} is missing." >&2
    exit 1
  fi

  git checkout --track origin/${branch}
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

echo
echo "${filename} diff:"

diff --color php-src/main/$filename $filename

rm $filename
