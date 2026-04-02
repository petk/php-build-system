cmake_minimum_required(VERSION 4.3...4.4)

project(PhpTestExtensionsVariables LANGUAGES NONE)

include(PHP/Core/Extensions)

set(
  extensions
  bcmath
  dom
  exif
  libxml
  mbstring
  pdo
  pdo_sqlite
  foo
  bar
)

set(
  options
  OFF
  ON
  ON
  ON
  OFF
  ON
  ON
  OFF
  OFF
)

set(CACHE{PHP_EXT_MBSTRING} VALUE ON)
set_property(CACHE PHP_EXT_MBSTRING PROPERTY STRINGS ON shared baz)
set(CACHE{PHP_EXT_FOO} VALUE "shared")
set(CACHE{PHP_EXT_BAR} VALUE "SHARED")

foreach(extension option IN ZIP_LISTS extensions options)
  php_extensions_pre_configure(${extension})

  string(TOUPPER "${extension}" extension_upper)
  option(PHP_EXT_${extension_upper} "" ${option})

  php_extensions_post_configure(${extension})
endforeach()

set(
  expected_values
  OFF
  ON
  ON
  ON
  ON
  ON
  ON
  "shared"
  "shared"
)

foreach(extension expected_value IN ZIP_LISTS extensions expected_values)
  string(TOUPPER "${extension}" extension_upper)

  if(NOT PHP_EXT_${extension_upper} STREQUAL expected_value)
    message(
      FATAL_ERROR
      "Expected value for ${extension} extension is ${expected_value} "
      "but the actual value is ${PHP_EXT_${extension_upper}}"
    )
  endif()
endforeach()

get_property(strings CACHE PHP_EXT_MBSTRING PROPERTY STRINGS)
set(expected "ON;shared;baz")
if(NOT strings STREQUAL expected)
  message(
    FATAL_ERROR
    "STRINGS property for ${extension} extension is ${expected} "
    "but the actual value is ${strings}"
  )
endif()
