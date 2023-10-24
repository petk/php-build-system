include(CheckCompilerFlag)
include(CheckLibraryExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(EXT_GD "Enable the gd extension" OFF)

cmake_dependent_option(
  EXT_GD_SHARED
  "Build the gd extension as a shared library"
  OFF
  "EXT_GD;NOT BUILD_SHARED_LIBS"
  OFF
)

cmake_dependent_option(
  EXT_GD_EXTERNAL
  "Use external libgd"
  OFF
  "EXT_GD"
  OFF
)

cmake_dependent_option(
  EXT_GD_AVIF
  "GD: Enable AVIF support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

cmake_dependent_option(
  EXT_GD_WEBP
  "GD: Enable WebP support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

cmake_dependent_option(
  EXT_GD_JPEG
  "GD: Enable JPEG support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

cmake_dependent_option(
  EXT_GD_XPM
  "GD: Enable XPM support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

cmake_dependent_option(
  EXT_GD_FREETYPE
  "GD: Enable FreeType 2 support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

cmake_dependent_option(
  EXT_GD_JIS
  "GD: Enable JIS-mapped Japanese font support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

if(NOT EXT_GD)
  return()
endif()

if(EXT_GD_SHARED)
  add_library(php_gd SHARED)
else()
  add_library(php_gd)
endif()

target_sources(php_gd PRIVATE
  gd.c
)

file(GLOB _gd_headers_files "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

if(NOT EXT_GD_EXTERNAL)
  target_sources(php_gd PRIVATE
    libgd/gd.c
    libgd/gd_gd.c
    libgd/gd_gd2.c
    libgd/gd_io.c
    libgd/gd_io_dp.c
    libgd/gd_io_file.c
    libgd/gd_ss.c
    libgd/gd_io_ss.c
    libgd/gd_webp.c
    libgd/gd_avif.c
    libgd/gd_png.c
    libgd/gd_jpeg.c
    libgd/gdxpm.c
    libgd/gdfontt.c
    libgd/gdfonts.c
    libgd/gdfontmb.c
    libgd/gdfontl.c
    libgd/gdfontg.c
    libgd/gdtables.c
    libgd/gdft.c
    libgd/gdcache.c
    libgd/gdkanji.c
    libgd/wbmp.c
    libgd/gd_wbmp.c
    libgd/gdhelpers.c
    libgd/gd_topal.c
    libgd/gd_gif_in.c
    libgd/gd_xbm.c
    libgd/gd_gif_out.c
    libgd/gd_security.c
    libgd/gd_filter.c
    libgd/gd_pixelate.c
    libgd/gd_rotate.c
    libgd/gd_color_match.c
    libgd/gd_transform.c
    libgd/gd_crop.c
    libgd/gd_interpolation.c
    libgd/gd_matrix.c
    libgd/gd_bmp.c
    libgd/gd_tga.c
  )

  set(HAVE_GD_BUNDLED 1 CACHE INTERNAL "Whether the bundled libgd is used")

  # With bundled GD library these are always available.
  set(HAVE_GD_PNG 1 CACHE INTERNAL "Whether the PNG functionality can be used with libgd")
  set(HAVE_GD_BMP 1 CACHE INTERNAL "Whether the BMP functionality can be used with libgd")
  set(HAVE_GD_TGA 1 CACHE INTERNAL "Whether the TGA functionality can be used with libgd")

  file(GLOB _gd_libgd_headers_files "${CMAKE_CURRENT_SOURCE_DIR}/libgd/*.h")
  list(APPEND _gd_headers_files ${_gd_libgd_headers_files})

  # Check for fabsf and floorf which are available since C99.
  # TODO: Are these checks still needed?
  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_LIBRARIES m)
    check_symbol_exists(fabsf "math.h" HAVE_FABSF)
    check_symbol_exists(floorf "math.h" HAVE_FLOORF)
  cmake_pop_check_state()

  if(HAVE_FABSF OR HAVE_FLOORF)
    target_link_libraries(php_gd PRIVATE m)
  endif()

  target_include_directories(php_gd PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/libgd")

  # Add -Wno-strict-prototypes C flag.
  check_compiler_flag(C -Wno-strict-prototypes HAVE_WNO_STRICT_PROTOTYPES_C)
  if(HAVE_WNO_STRICT_PROTOTYPES_C)
    target_compile_options(php_gd
      PRIVATE "$<$<COMPILE_LANGUAGE:C>:-Wno-strict-prototypes>"
    )
  endif()

  find_package(ZLIB REQUIRED)
  target_link_libraries(php_gd PRIVATE ZLIB::ZLIB)

  find_package(PNG REQUIRED)
  target_link_libraries(php_gd PRIVATE PNG::PNG)

  set(HAVE_LIBPNG 1 CACHE INTERNAL "Whether the libpng is available")

  if(EXT_GD_AVIF)
    find_package(libavif 0.8.2 REQUIRED)

    target_link_libraries(php_gd PRIVATE libavif::libavif)

    set(HAVE_LIBAVIF 1 CACHE INTERNAL "Whether the libavif is available")
    set(HAVE_GD_AVIF 1 CACHE INTERNAL "Whether the GD avif support is enabled")
  endif()

  if(EXT_GD_WEBP)
    find_package(WebP 0.2.0 REQUIRED)

    target_link_libraries(php_gd PRIVATE WebP::WebP)

    set(HAVE_LIBWEBP 1 CACHE INTERNAL "Whether the libwebp is available")
    set(HAVE_GD_WEBP 1 CACHE INTERNAL "Whether the GD WebP support is enabled")
  endif()

  if(EXT_GD_JPEG)
    find_package(JPEG REQUIRED)

    target_link_libraries(php_gd PRIVATE JPEG::JPEG)

    set(HAVE_LIBJPEG 1 CACHE INTERNAL "Whether the libjpeg is available")
    set(HAVE_GD_JPG 1 CACHE INTERNAL "Whether the GD JPEG support is enabled")
  endif()

  if(EXT_GD_XPM)
    find_package(XPM REQUIRED)

    target_link_libraries(php_gd PRIVATE XPM::XPM)

    set(HAVE_XPM 1 CACHE INTERNAL "Whether the libXpm library is available")
    set(HAVE_GD_XPM 1 CACHE INTERNAL "Whether the GD XPM support is enabled")
  endif()

  if(EXT_GD_FREETYPE)
    find_package(Freetype REQUIRED)

    target_link_libraries(php_gd PRIVATE Freetype::Freetype)

    set(HAVE_LIBFREETYPE 1 CACHE INTERNAL "Whether the FreeType library is available")
    set(HAVE_GD_FREETYPE 1 CACHE INTERNAL "Whether the GD FreeType support is enabled")
  endif()

  if(EXT_GD_JIS)
    set(JISX0208 1 CACHE INTERNAL "Whether to use the JIS-mapped Japanese font support in GD")
    set(USE_GD_JISX0208 1 CACHE INTERNAL "Whether the GD JIS-mapped Japanese font support is enabled")
  endif()

  # Sanity check.
  cmake_push_check_state(RESET)
    get_target_property(libraries php_gd LINK_LIBRARIES)
    set(CMAKE_REQUIRED_LIBRARIES ${libraries})

    check_c_source_compiles("
      char foobar(void) {
        return '\\\\0';
      }

      char foobar();

      int main(void) {
        foobar();
        return 0;
      }
    " GD_SANITY_CHECK_COMPILES)
  cmake_pop_check_state()

  if(NOT GD_SANITY_CHECK_COMPILES)
    message(FATAL_ERROR "GD build test failed. Please check logs for details.")
  endif()
else()
  find_package(GD 2.1.0 REQUIRED)

  target_link_libraries(php_gd PRIVATE GD::GD)

  target_sources(php_gd PRIVATE gd_compat.c)

  # Sanity check.
  check_library_exists(GD::GD gdImageCreate "" HAVE_LIBGD)

  if(NOT HAVE_LIBGD)
    message(
      FATAL_ERROR
      "GD build test failed to find gdImageCreate in libgd. Please check the "
      "logs for details."
    )
  endif()

  check_library_exists(GD::GD gdImageCreateFromPng "" HAVE_GD_PNG)
  check_library_exists(GD::GD gdImageCreateFromAvif "" HAVE_GD_AVIF)
  check_library_exists(GD::GD gdImageCreateFromWebp "" HAVE_GD_WEBP)
  check_library_exists(GD::GD gdImageCreateFromJpeg "" HAVE_GD_JPG)
  check_library_exists(GD::GD gdImageCreateFromXpm "" HAVE_GD_XPM)
  check_library_exists(GD::GD gdImageCreateFromBmp "" HAVE_GD_BMP)
  check_library_exists(GD::GD gdImageCreateFromTga "" HAVE_GD_TGA)
  check_library_exists(GD::GD gdImageStringFT "" HAVE_GD_FREETYPE)
  check_library_exists(GD::GD gdVersionString "" HAVE_GD_LIBVERSION)
  check_library_exists(GD::GD gdImageGetInterpolationMethod "" HAVE_GD_GET_INTERPOLATION)
endif()

target_sources(
  php_gd
  PUBLIC FILE_SET gd_headers
  TYPE HEADERS
  FILES ${_gd_headers_files}
)

install(
  TARGETS php_gd
  FILE_SET gd_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/php/ext/gd
)
