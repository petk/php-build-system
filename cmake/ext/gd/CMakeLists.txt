include(CheckLibraryExists)
include(CMakeDependentOption)
include(CMakePushCheckState)

option(gd "Whether to enable the GD extension" OFF)

cmake_dependent_option(gd_external "Whether to use external libgd" OFF "gd" OFF)
cmake_dependent_option(gd_avif "GD: Whether to enable AVIF support (only for bundled libgd)" OFF "gd;NOT gd_external" OFF)
cmake_dependent_option(gd_webp "GD: Whether to enable WEBP support (only for bundled libgd)" OFF "gd; NOT gd_external" OFF)
cmake_dependent_option(gd_jpeg "GD: Whether to enable JPEG support (only for bundled libgd)" OFF "gd; NOT gd_external" OFF)
cmake_dependent_option(gd_xpm "GD: Whether to enable XPM support (only for bundled libgd)" OFF "gd;NOT gd_external" OFF)
cmake_dependent_option(gd_freetype "GD: Whether to enable FreeType 2 support (only for bundled libgd)" OFF "gd; NOT gd_external" OFF)
cmake_dependent_option(gd_jis "GD: Whether to enable JIS-mapped Japanese font support (only for bundled libgd)" OFF "gd; NOT gd_external" OFF)

if(NOT gd)
  return()
endif()

string(TOLOWER ${gd} extension_lower)
set(extension_library_type "STATIC")
if(extension_lower STREQUAL "shared")
  set(extension_library_type "SHARED")
endif()

php_extension(NAME gd ${extension_library_type})

add_library(ext_gd ${extension_library_type}
  gd.c
)

file(GLOB GD_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*.h")

if(NOT gd_external)
  target_sources(ext_gd PRIVATE
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

  list(APPEND GD_HEADER_FILES "${CMAKE_CURRENT_SOURCE_DIR}/libgd/*.h")

  # TODO: Check for fabsf and floorf which are available since C99. Are these
  # checks still needed?
  cmake_push_check_state()
    set(CMAKE_REQUIRED_LIBRARIES "${CMAKE_REQUIRED_LIBRARIES} m")
    check_symbol_exists(fabsf "math.h" HAVE_FABSF)
    check_symbol_exists(floorf "math.h" HAVE_FLOORF)
  cmake_pop_check_state()

  if(HAVE_FABSF OR HAVE_FLOORF)
    target_link_libraries(ext_gd PRIVATE m)
  endif()

  target_include_directories(ext_gd PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/libgd")
  target_compile_options(ext_gd PRIVATE -Wno-strict-prototypes)

  find_package(ZLIB REQUIRED)

  if(ZLIB_LIBRARIES)
    target_link_libraries(ext_gd PRIVATE ${ZLIB_LIBRARIES})
  endif()

  if(ZLIB_INCLUDE_DIRS)
    target_include_directories(ext_gd PRIVATE ${ZLIB_INCLUDE_DIRS})
  endif()

  find_package(PNG REQUIRED)

  if(PNG_LIBRARIES)
    target_link_libraries(ext_gd PRIVATE ${PNG_LIBRARIES})
  endif()

  if(PNG_INCLUDE_DIRS)
    target_include_directories(ext_gd PRIVATE ${PNG_INCLUDE_DIRS})
  endif()

  if(PNG_FOUND)
    set(HAVE_LIBPNG 1 CACHE INTERNAL "Whether the libpng is available")
  endif()

  if(gd_avif)
    find_package(AVIF 0.8.2 REQUIRED)

    if(AVIF_FOUND)
      set(HAVE_LIBAVIF 1 CACHE INTERNAL "Whether the libavif is available")
    endif()

    set(HAVE_GD_AVIF 1 CACHE INTERNAL "Whether the GD avif support is enabled")

    if(AVIF_LIBRARIES)
      target_link_libraries(ext_gd PRIVATE ${AVIF_LIBRARIES})
    endif()

    if(AVIF_INCLUDE_DIRS)
      target_include_directories(ext_gd PRIVATE ${AVIF_INCLUDE_DIRS})
    endif()
  endif()

  if(gd_webp)
    find_package(WEBP 0.2.0 REQUIRED)

    if(WEBP_FOUND)
      set(HAVE_LIBWEBP 1 CACHE INTERNAL "Whether the libwebp is available")
    endif()

    set(HAVE_GD_WEBP 1 CACHE INTERNAL "Whether the GD webp support is enabled")

    if(WEBP_LIBRARIES)
      target_link_libraries(ext_gd PRIVATE ${WEBP_LIBRARIES})
    endif()

    if(WEBP_INCLUDE_DIRS)
      target_include_directories(ext_gd PRIVATE ${WEBP_INCLUDE_DIRS})
    endif()
  endif()

  if(gd_jpeg)
    find_package(JPEG REQUIRED)

    if(JPEG_FOUND)
      set(HAVE_LIBJPEG 1 CACHE INTERNAL "Whether the libjpeg is available")
    endif()

    set(HAVE_GD_JPG 1 CACHE INTERNAL "Whether the GD JPEG support is enabled")

    if(JPEG_LIBRARIES)
      target_link_libraries(ext_gd PRIVATE ${JPEG_LIBRARIES})
    endif()

    if(JPEG_INCLUDE_DIRS)
      target_include_directories(ext_gd PRIVATE ${JPEG_INCLUDE_DIRS})
    endif()
  endif()

  if(gd_xpm)
    find_package(XPM REQUIRED)

    if(XPM_FOUND)
      set(HAVE_XPM 1 CACHE INTERNAL "Whether the xpm library is available")
    endif()

    set(HAVE_GD_XPM 1 CACHE INTERNAL "Whether the GD XPM support is enabled")

    if(XPM_LIBRARIES)
      target_link_libraries(ext_gd PRIVATE ${XPM_LIBRARIES})
    endif()

    if(XPM_INCLUDE_DIRS)
      target_include_directories(ext_gd PRIVATE ${XPM_INCLUDE_DIRS})
    endif()
  endif()

  if(gd_freetype)
    find_package(Freetype REQUIRED)

    if(FREETYPE_FOUND)
      set(HAVE_LIBFREETYPE 1 CACHE INTERNAL "Whether the freetype library is available")
    endif()

    set(HAVE_GD_FREETYPE 1 CACHE INTERNAL "Whether the GD Freetype support is enabled")

    if(FREETYPE_LIBRARIES)
      target_link_libraries(ext_gd PRIVATE ${FREETYPE_LIBRARIES})
    endif()

    if(FREETYPE_INCLUDE_DIRS)
      target_include_directories(ext_gd PRIVATE ${FREETYPE_INCLUDE_DIRS})
    endif()
  endif()

  if(gd_jis)
    set(JISX0208 1 CACHE INTERNAL "Whether to use the JIS-mapped Japanese font support in GD")
    set(USE_GD_JISX0208 1 CACHE INTERNAL "Whether the GD JIS-mapped Japanese font support is enabled")
  endif()
else()
  find_package(GD 2.1.0 REQUIRED)
  target_sources(ext_gd PRIVATE gd_compat.c)

  if(GD_LIBRARIES)
    target_link_libraries(ext_gd PRIVATE ${GD_LIBRARIES})
  endif()

  if(GD_INCLUDE_DIRS)
    target_include_directories(ext_gd PRIVATE ${GD_INCLUDE_DIRS})
  endif()

  check_library_exists(gd gdImageCreate "" HAVE_LIBGD)

  if(NOT HAVE_LIBGD)
    message(FATAL_ERROR "GD build test failed to find gdImageCreate in libgd. Please check the logs for details.")
  endif()

  check_library_exists(gd gdImageCreateFromPng "" HAVE_GD_PNG)
  check_library_exists(gd gdImageCreateFromAvif "" HAVE_GD_AVIF)
  check_library_exists(gd gdImageCreateFromWebp "" HAVE_GD_WEBP)
  check_library_exists(gd gdImageCreateFromJpeg "" HAVE_GD_JPG)
  check_library_exists(gd gdImageCreateFromXpm "" HAVE_GD_XPM)
  check_library_exists(gd gdImageCreateFromBmp "" HAVE_GD_BMP)
  check_library_exists(gd gdImageCreateFromTga "" HAVE_GD_TGA)
  check_library_exists(gd gdImageStringFT "" HAVE_GD_FREETYPE)
  check_library_exists(gd gdVersionString "" HAVE_GD_LIBVERSION)
  check_library_exists(gd gdImageGetInterpolationMethod "" HAVE_GD_GET_INTERPOLATION)
endif()

set_target_properties(ext_gd PROPERTIES PUBLIC_HEADER "${GD_HEADER_FILES}")
