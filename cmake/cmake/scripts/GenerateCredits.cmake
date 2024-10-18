#!/usr/bin/env -S cmake -P
#
# Command-line script to regenerate the ext/standard/credits_*.h headers from
# CREDITS files.
#
# Run with: `cmake -P cmake/scripts/GenerateCredits.cmake`

if(NOT CMAKE_SCRIPT_MODE_FILE)
  message(FATAL_ERROR "This is a command-line script.")
endif()

set(PHP_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/../../)

if(NOT EXISTS ${PHP_SOURCE_DIR}/ext/standard/credits.h)
  message(FATAL_ERROR "This script should be run inside the php-src repository")
endif()

set(template [[
/*
                      DO NOT EDIT THIS FILE!

 it has been automatically created by scripts/dev/credits from
 the information found in the various ext/.../CREDITS and
 sapi/.../CREDITS files

 if you want to change an entry you have to edit the appropriate
 CREDITS file instead

*/

]])

file(GLOB credits ${PHP_SOURCE_DIR}/*/*/CREDITS)

foreach(credit ${credits})
  cmake_path(GET credit PARENT_PATH parent)
  cmake_path(GET parent PARENT_PATH parent)
  cmake_path(GET parent FILENAME dir)

  list(APPEND dirs ${dir})
  file(STRINGS ${credit} lines ENCODING UTF-8)
  list(GET lines 0 title)
  list(GET lines 1 authors)
  list(APPEND ${dir}_credits "CREDIT_LINE(\"${title}\", \"${authors}\")")
endforeach()

list(REMOVE_DUPLICATES dirs)

foreach(dir ${dirs})
  list(SORT ${dir}_credits CASE INSENSITIVE)
  list(JOIN ${dir}_credits ";\n" credits)
  set(content "${template}${credits};\n")

  if(EXISTS ${PHP_SOURCE_DIR}/ext/standard/credits_${dir}.h)
    file(READ ${PHP_SOURCE_DIR}/ext/standard/credits_${dir}.h current)
    if(content STREQUAL "${current}")
      continue()
    endif()
  endif()

  file(WRITE ${PHP_SOURCE_DIR}/ext/standard/credits_${dir}.h "${content}")
  message("Updated ext/standard/credits_${dir}.h")
endforeach()