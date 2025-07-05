#[=============================================================================[
# The gd extension

Configure the `gd` extension.

This extension provides image processing and graphics draw (GD) support.

## PHP_EXT_GD

* Default: `OFF`
* Values: `ON|OFF`

Enable the extension.

## PHP_EXT_GD_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Build extension as shared.

## PHP_EXT_GD_EXTERNAL

* Default: `OFF`
* Values: `ON|OFF`

Use external (system) GD library instead of the bundled libgd from PHP sources.

## PHP_EXT_GD_AVIF

* Default: `OFF`
* Values: `ON|OFF`

Enable AVIF support (only for bundled libgd).

## PHP_EXT_GD_WEBP

* Default: `OFF`
* Values: `ON|OFF`

Enable WebP support (only for bundled libgd).

## PHP_EXT_GD_JPEG

* Default: `OFF`
* Values: `ON|OFF`

Enable JPEG support (only for bundled libgd).

## PHP_EXT_GD_XPM

* Default: `OFF`
* Values: `ON|OFF`

Enable XPM support (only for bundled libgd).

## PHP_EXT_GD_FREETYPE

* Default: `OFF`
* Values: `ON|OFF`

Enable FreeType 2 support (only for bundled libgd).

## PHP_EXT_GD_JIS

* Default: `OFF`
* Values: `ON|OFF`

Enable JIS-mapped (Japanese Industrial Standards) Japanese font support (only
for bundled libgd).
#]=============================================================================]

cmake_minimum_required(VERSION 3.29...4.0)

project(
  PhpExtensionGd
  LANGUAGES C
)

include(CheckSourceRuns)
include(CheckSymbolExists)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)
include(PHP/CheckCompilerFlag)
include(PHP/SearchLibraries)

option(PHP_EXT_GD "Enable the gd extension")

add_feature_info(
  "ext/gd"
  PHP_EXT_GD
  "image processing and graphics draw (GD)"
)

cmake_dependent_option(
  PHP_EXT_GD_SHARED
  "Build the gd extension as a shared library"
  OFF
  PHP_EXT_GD
  OFF
)

cmake_dependent_option(
  PHP_EXT_GD_EXTERNAL
  "Use external (system) GD library instead of the bundled libgd from PHP sources"
  OFF
  PHP_EXT_GD
  OFF
)

add_feature_info(
  "ext/gd external GD"
  PHP_EXT_GD_EXTERNAL
  "system libgd instead of bundled"
)

cmake_dependent_option(
  PHP_EXT_GD_AVIF
  "GD: Enable AVIF support (only for bundled libgd)"
  OFF
  [[PHP_EXT_GD AND NOT PHP_EXT_GD_EXTERNAL]]
  OFF
)

add_feature_info(
  "ext/gd AVIF"
  PHP_EXT_GD_AVIF
  "AV1 Image File Format support"
)

cmake_dependent_option(
  PHP_EXT_GD_WEBP
  "GD: Enable WebP support (only for bundled libgd)"
  OFF
  [[PHP_EXT_GD AND NOT PHP_EXT_GD_EXTERNAL]]
  OFF
)

add_feature_info(
  "ext/gd WebP"
  PHP_EXT_GD_WEBP
  "WebP support"
)

cmake_dependent_option(
  PHP_EXT_GD_JPEG
  "GD: Enable JPEG support (only for bundled libgd)"
  OFF
  [[PHP_EXT_GD AND NOT PHP_EXT_GD_EXTERNAL]]
  OFF
)

add_feature_info(
  "ext/gd JPEG"
  PHP_EXT_GD_JPEG
  "JPEG support"
)

cmake_dependent_option(
  PHP_EXT_GD_XPM
  "GD: Enable XPM support (only for bundled libgd)"
  OFF
  [[PHP_EXT_GD AND NOT PHP_EXT_GD_EXTERNAL]]
  OFF
)

add_feature_info(
  "ext/gd XPM"
  PHP_EXT_GD_XPM
  "X PixMap support"
)

cmake_dependent_option(
  PHP_EXT_GD_FREETYPE
  "GD: Enable FreeType 2 support (only for bundled libgd)"
  OFF
  [[PHP_EXT_GD AND NOT PHP_EXT_GD_EXTERNAL]]
  OFF
)

add_feature_info(
  "ext/gd FreeType"
  PHP_EXT_GD_FREETYPE
  "support for rendering text to bitmaps"
)

cmake_dependent_option(
  PHP_EXT_GD_JIS
  "GD: Enable JIS-mapped Japanese font support (only for bundled libgd)"
  OFF
  [[PHP_EXT_GD AND NOT PHP_EXT_GD_EXTERNAL]]
  OFF
)

add_feature_info(
  "ext/gd JIS"
  PHP_EXT_GD_JIS
  "JIS-mapped Japanese font support"
)

if(NOT PHP_EXT_GD)
  return()
endif()

if(PHP_EXT_GD_SHARED)
  add_library(php_ext_gd MODULE)
else()
  add_library(php_ext_gd OBJECT)
endif()

target_sources(
  php_ext_gd
  PRIVATE
    gd.c
    gd.stub.php
  PUBLIC
    FILE_SET HEADERS
      FILES
        gd_arginfo.h
        gd_compat.h
        php_gd.h
)

if(NOT PHP_EXT_GD_EXTERNAL)
  target_sources(
    php_ext_gd
    PRIVATE
      libgd/gd_avif.c
      libgd/gd_bmp.c
      libgd/gd_color_match.c
      libgd/gd_crop.c
      libgd/gd_filter.c
      libgd/gd_gd.c
      libgd/gd_gd2.c
      libgd/gd_gif_in.c
      libgd/gd_gif_out.c
      libgd/gd_interpolation.c
      libgd/gd_io_dp.c
      libgd/gd_io_file.c
      libgd/gd_io_ss.c
      libgd/gd_io.c
      libgd/gd_jpeg.c
      libgd/gd_matrix.c
      libgd/gd_pixelate.c
      libgd/gd_png.c
      libgd/gd_rotate.c
      libgd/gd_security.c
      libgd/gd_ss.c
      libgd/gd_tga.c
      libgd/gd_topal.c
      libgd/gd_transform.c
      libgd/gd_wbmp.c
      libgd/gd_webp.c
      libgd/gd_xbm.c
      libgd/gd.c
      libgd/gdcache.c
      libgd/gdfontg.c
      libgd/gdfontl.c
      libgd/gdfontmb.c
      libgd/gdfonts.c
      libgd/gdfontt.c
      libgd/gdft.c
      libgd/gdhelpers.c
      libgd/gdkanji.c
      libgd/gdtables.c
      libgd/gdxpm.c
      libgd/wbmp.c
    PUBLIC
      FILE_SET HEADERS
        FILES
          libgd/bmp.h
          libgd/gd_errors.h
          libgd/gd_intern.h
          libgd/gd_io.h
          libgd/gd_tga.h
          libgd/gd.h
          libgd/gdcache.h
          libgd/gdfontg.h
          libgd/gdfontl.h
          libgd/gdfontmb.h
          libgd/gdfonts.h
          libgd/gdfontt.h
          libgd/gdhelpers.h
          libgd/jisx0208.h
          libgd/wbmp.h
  )

  set(HAVE_GD_BUNDLED TRUE)

  # With bundled GD library these are always available.
  set(HAVE_GD_PNG TRUE)
  set(HAVE_GD_BMP TRUE)
  set(HAVE_GD_TGA TRUE)

  target_compile_definitions(
    php_ext_gd
    PRIVATE
      # Bundled GD library uses the C99 standard fabsf and floorf conditionally.
      HAVE_FABSF=1
      HAVE_FLOORF=1
  )

  php_search_libraries(
    floorf
    HEADERS math.h
    LIBRARIES m
    VARIABLE PHP_EXT_GD_HAS_FLOORF
    TARGET php_ext_gd PRIVATE
  )

  target_include_directories(php_ext_gd PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/libgd)

  # Add -Wno-strict-prototypes C flag: https://github.com/php/php-src/pull/10803
  php_check_compiler_flag(C -Wno-strict-prototypes PHP_HAS_WNO_STRICT_PROTOTYPES)
  if(PHP_HAS_WNO_STRICT_PROTOTYPES)
    target_compile_options(
      php_ext_gd
      PRIVATE
        $<$<COMPILE_LANGUAGE:C>:-Wno-strict-prototypes>
    )
  endif()

  find_package(ZLIB ${PHP_ZLIB_MIN_VERSION})
  set_package_properties(
    ZLIB
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the gd extension."
  )

  target_link_libraries(php_ext_gd PRIVATE ZLIB::ZLIB)

  find_package(PNG)
  set_package_properties(
    PNG
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the gd extension."
  )

  target_link_libraries(php_ext_gd PRIVATE PNG::PNG)

  set(HAVE_LIBPNG TRUE)

  if(PHP_EXT_GD_AVIF)
    find_package(libavif 0.8.2)
    set_package_properties(
      libavif
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable the AVIF support in the gd extension."
    )

    target_link_libraries(php_ext_gd PRIVATE libavif::libavif)

    set(HAVE_LIBAVIF TRUE)
    set(HAVE_GD_AVIF TRUE)
  endif()

  if(PHP_EXT_GD_WEBP)
    find_package(WebP 0.2.0)
    set_package_properties(
      WebP
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable the WebP support in the gd extension."
    )

    target_link_libraries(php_ext_gd PRIVATE WebP::WebP)

    set(HAVE_LIBWEBP TRUE)
    set(HAVE_GD_WEBP TRUE)
  endif()

  if(PHP_EXT_GD_JPEG)
    find_package(JPEG)
    set_package_properties(
      JPEG
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable the JPEG support in the gd extension."
    )

    target_link_libraries(php_ext_gd PRIVATE JPEG::JPEG)

    set(HAVE_LIBJPEG TRUE)
    set(HAVE_GD_JPG TRUE)
  endif()

  if(PHP_EXT_GD_XPM)
    find_package(XPM)
    set_package_properties(
      XPM
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable the XPM support in the gd extension."
    )

    target_link_libraries(php_ext_gd PRIVATE XPM::XPM)

    set(HAVE_XPM TRUE)
    set(HAVE_GD_XPM TRUE)
  endif()

  if(PHP_EXT_GD_FREETYPE)
    find_package(Freetype)
    set_package_properties(
      Freetype
      PROPERTIES
        TYPE REQUIRED
        PURPOSE "Necessary to enable the Freetype support in the gd extension."
    )

    target_link_libraries(php_ext_gd PRIVATE Freetype::Freetype)

    set(HAVE_LIBFREETYPE TRUE)
    set(HAVE_GD_FREETYPE TRUE)
  endif()

  if(PHP_EXT_GD_JIS)
    set(JISX0208 TRUE)
    set(USE_GD_JISX0208 TRUE)
  endif()
else()
  find_package(GD 2.1.0)
  set_package_properties(
    GD
    PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the gd extension with external GD library."
  )

  target_link_libraries(php_ext_gd PRIVATE GD::GD)

  target_sources(php_ext_gd PRIVATE gd_compat.c)

  if(TARGET GD::GD)
    set(HAVE_LIBGD TRUE)

    # Build and run a program to determine if GD has support for the given
    # format. The first argument is the proper-noun-capitalized name of the
    # format -- basically the word Foo in gdImageCreateFromFoo -- such as Png.
    # If support for format Foo exists, the second argument (the name of a
    # constant) will be defined to 1. The reason for this charade is that gd
    # defines "junk" versions of each gdImageCreateFromFoo function even when it
    # does not support the Foo format. Those junk functions display a warning
    # but eventually return normally, making a simple link or run test
    # insufficient.
    function(php_ext_gd_check_format format result)
      cmake_push_check_state(RESET)
        set(CMAKE_REQUIRED_LIBRARIES GD::GD)

        # gdImageCreateFromXpm() expects 'char *' type.
        if(format STREQUAL "Xpm")
          set(definition [[char* f = "test.xpm"]])
        else()
          set(definition "FILE* f = NULL")
        endif()

        check_source_runs(C "
          #include <stdio.h>
          #include <unistd.h>
          #include <gd.h>

          /* A custom gdErrorMethod */
          void exit1(int priority, const char *format, va_list args)
          {
            (void)priority;
            (void)format;
            (void)args;
            _exit(1);
          }

          int main(void)
          {
            ${definition};

            /* Override the default gd_error_method with one that actually
                causes the program to return an error. */
            gdSetErrorMethod(exit1);

            gdImagePtr p = gdImageCreateFrom${format}(f);
            (void)p;

            return 0;
          }" ${result})

      cmake_pop_check_state()
    endfunction()

    php_ext_gd_check_format(Png HAVE_GD_PNG)
    php_ext_gd_check_format(Avif HAVE_GD_AVIF)
    php_ext_gd_check_format(Webp HAVE_GD_WEBP)
    php_ext_gd_check_format(Jpeg HAVE_GD_JPG)
    php_ext_gd_check_format(Xpm HAVE_GD_XPM)
    php_ext_gd_check_format(Bmp HAVE_GD_BMP)
    php_ext_gd_check_format(Tga HAVE_GD_TGA)

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES GD::GD)

      check_symbol_exists(gdFontCacheShutdown gd.h HAVE_GD_FREETYPE)
      check_symbol_exists(gdVersionString gd.h HAVE_GD_LIBVERSION)
      check_symbol_exists(
        gdImageGetInterpolationMethod
        gd.h
        HAVE_GD_GET_INTERPOLATION
      )
    cmake_pop_check_state()
  endif()
endif()

configure_file(cmake/config.h.in config.h)
