#[=============================================================================[
Enable extensions to C or Posix on systems that by default disable them to
conform to standards or namespace issues.

Inspired by Autoconf's AC_USE_SYSTEM_EXTENSIONS macro.

The following cache variables are defined unconditionally:

  _GNU_SOURCE
  _DARWIN_C_SOURCE
  _NETBSD_SOURCE
  _OPENBSD_SOURCE
  _ALL_SOURCE
  _TANDEM_SOURCE
  _POSIX_PTHREAD_SEMANTICS
]=============================================================================]#

include_guard(GLOBAL)

set(_GNU_SOURCE 1 CACHE INTERNAL "Enable GNU extensions on systems that have them.")
set(_DARWIN_C_SOURCE 1 CACHE INTERNAL "Enable general extensions on macOS.")
set(_NETBSD_SOURCE 1 CACHE INTERNAL "Enable general extensions on NetBSD. Enable NetBSD compatibility extensions on Minix.")
set(_OPENBSD_SOURCE 1 CACHE INTERNAL "Enable OpenBSD compatibility extensions on NetBSD. Oddly enough, this does nothing on OpenBSD.")
set(_ALL_SOURCE 1 CACHE INTERNAL "Enable extensions on AIX 3, Interix.")
set(_TANDEM_SOURCE 1 CACHE INTERNAL "Enable extensions on HP NonStop.")
set(_POSIX_PTHREAD_SEMANTICS 1 CACHE INTERNAL "Enable POSIX-compatible threading on Solaris.")
set(__EXTENSIONS__ 1 CACHE INTERNAL "Enable general extensions on Solaris.")
set(__STDC_WANT_IEC_60559_ATTRIBS_EXT__ 1 CACHE INTERNAL "Enable extensions specified by ISO/IEC TS 18661-5:2014.")
set(__STDC_WANT_IEC_60559_BFP_EXT__ 1 CACHE INTERNAL "Enable extensions specified by ISO/IEC TS 18661-1:2014.")
set(__STDC_WANT_IEC_60559_DFP_EXT__ 1 CACHE INTERNAL "Enable extensions specified by ISO/IEC TS 18661-2:2015.")
set(__STDC_WANT_IEC_60559_TYPES_EXT__ 1 CACHE INTERNAL "Enable extensions specified by ISO/IEC TS 18661-3:2015.")
set(__STDC_WANT_IEC_60559_FUNCS_EXT__ 1 CACHE INTERNAL "Enable extensions specified by ISO/IEC TS 18661-4:2015.")
set(__STDC_WANT_LIB_EXT2__ 1 CACHE INTERNAL "Enable extensions specified by ISO/IEC TR 24731-2:2010.")
set(__STDC_WANT_MATH_SPEC_FUNCS__ 1 CACHE INTERNAL "Enable extensions specified by ISO/IEC 24747:2009.")
set(_HPUX_ALT_XOPEN_SOCKET_API 1 CACHE INTERNAL "Enable X/Open compliant socket functions that do not require linking with -lxnet on HP-UX 11.11.")
