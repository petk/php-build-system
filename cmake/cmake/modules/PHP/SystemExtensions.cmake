#[=============================================================================[
Enable extensions to C or Posix on systems that by default disable them to
conform to standards or namespace issues.

Inspired by Autoconf's AC_USE_SYSTEM_EXTENSIONS macro.

The following cache variables are defined unconditionally:

  _GNU_SOURCE
]=============================================================================]#

include_guard(GLOBAL)

set(_GNU_SOURCE 1 CACHE INTERNAL "Enable GNU extensions on systems that have them.")
set(_TANDEM_SOURCE 1 CACHE INTERNAL "Enable extensions on HP NonStop.")
set(__STDC_WANT_MATH_SPEC_FUNCS__ 1 CACHE INTERNAL "Enable extensions specified by ISO/IEC 24747:2009.")
set(__STDC_WANT_LIB_EXT2__ 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_FUNCS_EXT__ 1 CACHE INTERNAL "")
set(STDC_HEADERS 1 CACHE INTERNAL "")
set(_ALL_SOURCE 1 CACHE INTERNAL "")
set(__EXTENSIONS__ 1 CACHE INTERNAL "")
set(_POSIX_PTHREAD_SEMANTICS 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_ATTRIBS_EXT__ 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_BFP_EXT__ 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_DFP_EXT__ 1 CACHE INTERNAL "")
set(__STDC_WANT_IEC_60559_TYPES_EXT__ 1 CACHE INTERNAL "")
set(_OPENBSD_SOURCE 1 CACHE INTERNAL "")
set(_NETBSD_SOURCE 1 CACHE INTERNAL "")
set(_HPUX_ALT_XOPEN_SOCKET_API 1 CACHE INTERNAL "")
