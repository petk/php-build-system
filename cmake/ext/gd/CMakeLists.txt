include(CheckCompilerFlag)
include(CheckLibraryExists)
include(CheckSourceCompiles)
include(CMakeDependentOption)
include(CMakePushCheckState)
include(FeatureSummary)

option(EXT_GD "Enable the gd extension" OFF)

add_feature_info("ext/gd" EXT_GD
  "Image processing and graphics draw (GD) support."
)

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

add_feature_info("ext/gd with external GD library" EXT_GD_EXTERNAL
  "Support for external GD library instead of bundled one."
)

cmake_dependent_option(
  EXT_GD_AVIF
  "GD: Enable AVIF support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

add_feature_info("ext/gd AVIF" EXT_GD_AVIF
  "AVIF support for gd extension."
)

cmake_dependent_option(
  EXT_GD_WEBP
  "GD: Enable WebP support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

add_feature_info("ext/gd WebP" EXT_GD_WEBP
  "WebP support for gd extension."
)

cmake_dependent_option(
  EXT_GD_JPEG
  "GD: Enable JPEG support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

add_feature_info("ext/gd JPEG" EXT_GD_JPEG
  "JPEG support for gd extension."
)

cmake_dependent_option(
  EXT_GD_XPM
  "GD: Enable XPM support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

add_feature_info("ext/gd XPM" EXT_GD_XPM
  "XPM support for gd extension."
)

cmake_dependent_option(
  EXT_GD_FREETYPE
  "GD: Enable FreeType 2 support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

add_feature_info("ext/gd FreeType" EXT_GD_FREETYPE
  "FreeType 2 support for gd extension."
)

cmake_dependent_option(
  EXT_GD_JIS
  "GD: Enable JIS-mapped Japanese font support (only for bundled libgd)"
  OFF
  "EXT_GD;NOT EXT_GD_EXTERNAL"
  OFF
)

add_feature_info("ext/gd JIS" EXT_GD_JIS
  "JIS-mapped Japanese font support for gd extension (only for bundled libgd)."
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

file(GLOB _php_gd_headers "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

if(NOT EXT_GD_EXTERNAL)
  target_sources(php_gd PRIVATE
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
  )

  set(HAVE_GD_BUNDLED 1 CACHE INTERNAL "Whether the bundled libgd is used")

  # With bundled GD library these are always available.
  set(
    HAVE_GD_PNG 1
    CACHE INTERNAL "Whether the PNG functionality can be used with libgd"
  )

  set(
    HAVE_GD_BMP 1
    CACHE INTERNAL "Whether the BMP functionality can be used with libgd"
  )

  set(
    HAVE_GD_TGA 1
    CACHE INTERNAL "Whether the TGA functionality can be used with libgd"
  )

  file(GLOB _php_gd_libgd_headers "${CMAKE_CURRENT_SOURCE_DIR}/libgd/*.h")
  list(APPEND _php_gd_headers ${_php_gd_libgd_headers})

  # Check for fabsf and floorf which are available since C99.
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

  find_package(ZLIB)
  set_package_properties(ZLIB PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the gd extension."
  )

  target_link_libraries(php_gd PRIVATE ZLIB::ZLIB)

  find_package(PNG)
  set_package_properties(PNG PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the gd extension."
  )

  target_link_libraries(php_gd PRIVATE PNG::PNG)

  set(HAVE_LIBPNG 1 CACHE INTERNAL "Whether the libpng is available")

  if(EXT_GD_AVIF)
    find_package(libavif 0.8.2)
    set_package_properties(libavif PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the AVIF support in the gd extension."
    )

    target_link_libraries(php_gd PRIVATE libavif::libavif)

    set(HAVE_LIBAVIF 1 CACHE INTERNAL "Whether the libavif is available")
    set(HAVE_GD_AVIF 1 CACHE INTERNAL "Whether the AVIF support is enabled")
  endif()

  if(EXT_GD_WEBP)
    find_package(WebP 0.2.0)
    set_package_properties(WebP PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the WebP support in the gd extension."
    )

    target_link_libraries(php_gd PRIVATE WebP::WebP)

    set(HAVE_LIBWEBP 1 CACHE INTERNAL "Whether the libwebp is available")
    set(HAVE_GD_WEBP 1 CACHE INTERNAL "Whether the WebP support is enabled")
  endif()

  if(EXT_GD_JPEG)
    find_package(JPEG)
    set_package_properties(JPEG PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the JPEG support in the gd extension."
    )

    target_link_libraries(php_gd PRIVATE JPEG::JPEG)

    set(HAVE_LIBJPEG 1 CACHE INTERNAL "Whether the libjpeg is available")
    set(HAVE_GD_JPG 1 CACHE INTERNAL "Whether the JPEG support is enabled")
  endif()

  if(EXT_GD_XPM)
    find_package(XPM)
    set_package_properties(XPM PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the XPM support in the gd extension."
    )

    target_link_libraries(php_gd PRIVATE XPM::XPM)

    set(HAVE_XPM 1 CACHE INTERNAL "Whether the libXpm library is available")
    set(HAVE_GD_XPM 1 CACHE INTERNAL "Whether the XPM support is enabled")
  endif()

  if(EXT_GD_FREETYPE)
    find_package(Freetype)
    set_package_properties(Freetype PROPERTIES
      TYPE REQUIRED
      PURPOSE "Necessary to enable the Freetype support in the gd extension."
    )

    target_link_libraries(php_gd PRIVATE Freetype::Freetype)

    set(
      HAVE_LIBFREETYPE 1
      CACHE INTERNAL "Whether the FreeType library is available"
    )

    set(
      HAVE_GD_FREETYPE 1
      CACHE INTERNAL "Whether the FreeType support is enabled"
    )
  endif()

  if(EXT_GD_JIS)
    set(
      JISX0208 1
      CACHE INTERNAL "Whether the JIS-mapped Japanese font support is available"
    )

    set(
      USE_GD_JISX0208 1
      CACHE INTERNAL "Whether the JIS-mapped Japanese font support is enabled"
    )
  endif()

  # Do sanity check when all required packages are found.
  get_target_property(libraries php_gd LINK_LIBRARIES)
  set(_php_do_sanity_check TRUE)
  foreach(library ${libraries})
    if(library MATCHES "^.+::.+$" AND NOT TARGET ${library})
      set(_php_do_sanity_check FALSE)
      break()
    endif()
  endforeach()

  if(_php_do_sanity_check)
    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_LIBRARIES ${libraries})

      check_source_compiles(C [[
        char foobar(void) {
          return '\0';
        }

        char foobar();

        int main(void) {
          foobar();
          return 0;
        }
      ]] GD_SANITY_CHECK_COMPILES)
    cmake_pop_check_state()

    if(NOT GD_SANITY_CHECK_COMPILES)
      message(FATAL_ERROR "GD build test failed. Please check logs for details.")
    endif()
  endif()
else()
  find_package(GD 2.1.0)
  set_package_properties(GD PROPERTIES
    TYPE REQUIRED
    PURPOSE "Necessary to enable the gd extension with external GD library."
  )

  target_link_libraries(php_gd PRIVATE GD::GD)

  target_sources(php_gd PRIVATE gd_compat.c)

  if(TARGET GD::GD)
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
endif()

target_sources(
  php_gd
  PUBLIC FILE_SET HEADERS
    BASE_DIRS "${PROJECT_SOURCE_DIR}"
    FILES
      ${_php_gd_headers}
)

install(
  TARGETS php_gd
  ARCHIVE EXCLUDE_FROM_ALL
  FILE_SET HEADERS
)
