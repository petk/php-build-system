#[=============================================================================[
Checks for x87 floating point internal precision control.

See: https://wiki.php.net/rfc/rounding

The module defines the following variables:

``HAVE__FPU_SETCW``
  Defined to 1 if _FPU_SETCW is usable.

``HAVE_FPSETPREC``
  Defined to 1 if fpsetprec is present and usable.

``HAVE__CONTROLFP``
  Defined to 1 if _controlfp is present and usable.

``HAVE__CONTROLFP_S``
  Defined to 1 if _controlfp_s is present and usable.

``HAVE_FPU_INLINE_ASM_X86``
  Defined to 1 if FPU control word can be manipulated by inline assembler.
]=============================================================================]#

include(CheckCSourceRuns)

# _FPU_SETCW
message(STATUS "Checking for usable _FPU_SETCW")

check_c_source_runs("
  #include <fpu_control.h>

  int main() {
    fpu_control_t fpu_oldcw, fpu_cw;
    volatile double result;
    double a = 2877.0;
    volatile double b = 1000000.0;

    _FPU_GETCW(fpu_oldcw);
    fpu_cw = (fpu_oldcw & ~_FPU_EXTENDED & ~_FPU_SINGLE) | _FPU_DOUBLE;
    _FPU_SETCW(fpu_cw);
    result = a / b;
    _FPU_SETCW(fpu_oldcw);

    return 0;
  }
" HAVE__FPU_SETCW)

if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: No")
elseif(NOT HAVE__FPU_SETCW)
  message(STATUS "_FPU_SETCW is not usable")
else()
  set(HAVE__FPU_SETCW 1 CACHE STRING "whether _FPU_SETCW is present and usable")
  message(STATUS "_FPU_SETCW is usable")
endif()

# fpsetprec
message(STATUS "Checking for usable fpsetprec")

check_c_source_runs("
  #include <machine/ieeefp.h>

  int main() {
    fp_prec_t fpu_oldprec;
    volatile double result;
    double a = 2877.0;
    volatile double b = 1000000.0;

    fpu_oldprec = fpgetprec();
    fpsetprec(FP_PD);
    result = a / b;
    fpsetprec(fpu_oldprec);

    return 0;
  }
" HAVE_FPSETPREC)

if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: No")
elseif(NOT HAVE_FPSETPREC)
  message(STATUS "fpsetprec is not present")
else()
  set(HAVE_FPSETPREC 1 CACHE STRING "whether fpsetprec is present and usable")
  message(STATUS "fpsetprec is present and usable")
endif()

#_controlfp
message(STATUS "Checking for usable _controlfp")

check_c_source_runs("
  #include <float.h>

  int main() {
    unsigned int fpu_oldcw;
    volatile double result;
    double a = 2877.0;
    volatile double b = 1000000.0;

    fpu_oldcw = _controlfp(0, 0);
    _controlfp(_PC_53, _MCW_PC);
    result = a / b;
    _controlfp(fpu_oldcw, _MCW_PC);

    return 0;
  }
" HAVE__CONTROLFP)

if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: No")
elseif(NOT HAVE__CONTROLFP)
  message(STATUS "_controlfp is not present")
else()
  set(HAVE__CONTROLFP 1 CACHE STRING "whether _controlfp is present and usable")
  message(STATUS "_controlfp is present and usable")
endif()

# _controlfp_s
message(STATUS "Checking for usable _controlfp_s")

check_c_source_runs("
  #include <float.h>

  int main() {
    unsigned int fpu_oldcw, fpu_cw;
    volatile double result;
    double a = 2877.0;
    volatile double b = 1000000.0;

    _controlfp_s(&fpu_cw, 0, 0);
    fpu_oldcw = fpu_cw;
    _controlfp_s(&fpu_cw, _PC_53, _MCW_PC);
    result = a / b;
    _controlfp_s(&fpu_cw, fpu_oldcw, _MCW_PC);

    return 0;
  }
" HAVE__CONTROLFP_S)

if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: No")
elseif(NOT HAVE__CONTROLFP_S)
  message(STATUS "_controlfp_s is not present")
else()
  set(HAVE__CONTROLFP_S 1 CACHE STRING "whether _controlfp_s is present and usable")
  message(STATUS "_controlfp_s is present and usable")
endif()

# FPU control word manipulation
message(STATUS "Checking whether FPU control word can be manipulated by inline assembler")

check_c_source_runs("
  int main() {
    unsigned int oldcw, cw;
    volatile double result;
    double a = 2877.0;
    volatile double b = 1000000.0;

    __asm__ __volatile__ (\"fnstcw %0\" : \"=m\" (*&oldcw));
    cw = (oldcw & ~0x0 & ~0x300) | 0x200;
    __asm__ __volatile__ (\"fldcw %0\" : : \"m\" (*&cw));

    result = a / b;

    __asm__ __volatile__ (\"fldcw %0\" : : \"m\" (*&oldcw));

    return 0;
  }
" HAVE_FPU_INLINE_ASM_X86)

if(CMAKE_CROSSCOMPILING)
  message(STATUS "Cross-compiling: No")
elseif(NOT HAVE_FPU_INLINE_ASM_X86)
  message(STATUS "No")
else()
  set(HAVE_FPU_INLINE_ASM_X86 1 CACHE STRING "whether FPU control word can be manipulated by inline assembler")
  message(STATUS "yes")
endif()
