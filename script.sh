#!/bin/sh
#

if make -h 2>&1 | grep -q "\[-j max_jobs\]" \
  || make -h 2>&1 | grep -q "\-j dmake_max_jobs"; then
  # Linux, illumos has nproc, macOS and some BSD-based systems have sysctl.
  if command -v nproc > /dev/null; then
    jobs="$(nproc)"
  elif command -v sysctl > /dev/null; then
    jobs="$(sysctl -n hw.ncpu)"
  fi
fi

