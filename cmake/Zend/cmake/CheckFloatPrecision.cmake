#[=============================================================================[
# CheckFloatPrecision

Check for x87 floating point internal precision control.

See: https://wiki.php.net/rfc/rounding

## Cache variables

* `HAVE__FPU_SETCW`

  Whether `_FPU_SETCW` is usable.

* `HAVE_FPSETPREC`

  Whether `fpsetprec` is present and usable.

* `HAVE__CONTROLFP`

  Whether `_controlfp` is present and usable.

* `HAVE__CONTROLFP_S`

  Whether `_controlfp_s` is present and usable.

* `HAVE_FPU_INLINE_ASM_X86`

  Whether FPU control word can be manipulated by inline assembler.
#]=============================================================================]

include_guard(GLOBAL)

include(CheckSourceCompiles)
include(CMakePushCheckState)

cmake_push_check_state(RESET)
  set(CMAKE_REQUIRED_QUIET TRUE)

  # Obsolete in favor of C99 fenv.h functions to control FPU rounding modes.
  message(CHECK_START "Checking for usable _FPU_SETCW")
  check_source_compiles(C [[
    #include <fpu_control.h>

    int main(void)
    {
      fpu_control_t fpu_oldcw, fpu_cw;
      volatile double result;
      double a = 2877.0;
      volatile double b = 1000000.0;

      _FPU_GETCW(fpu_oldcw);
      fpu_cw = (fpu_oldcw & ~_FPU_EXTENDED & ~_FPU_SINGLE) | _FPU_DOUBLE;
      _FPU_SETCW(fpu_cw);
      result = a / b;
      _FPU_SETCW(fpu_oldcw);
      (void)result;

      return 0;
    }
  ]] HAVE__FPU_SETCW)
  if(HAVE__FPU_SETCW)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(CHECK_START "Checking for usable fpsetprec")
  check_source_compiles(C [[
    #include <machine/ieeefp.h>

    int main(void)
    {
      fp_prec_t fpu_oldprec;
      volatile double result;
      double a = 2877.0;
      volatile double b = 1000000.0;

      fpu_oldprec = fpgetprec();
      fpsetprec(FP_PD);
      result = a / b;
      fpsetprec(fpu_oldprec);
      (void)result;

      return 0;
    }
  ]] HAVE_FPSETPREC)
  if(HAVE_FPSETPREC)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(CHECK_START "Checking for usable _controlfp")
  check_source_compiles(C [[
    #include <float.h>

    int main(void)
    {
      unsigned int fpu_oldcw;
      volatile double result;
      double a = 2877.0;
      volatile double b = 1000000.0;

      fpu_oldcw = _controlfp(0, 0);
      _controlfp(_PC_53, _MCW_PC);
      result = a / b;
      _controlfp(fpu_oldcw, _MCW_PC);
      (void)result;

      return 0;
    }
  ]] HAVE__CONTROLFP)
  if(HAVE__CONTROLFP)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(CHECK_START "Checking for usable _controlfp_s")
  check_source_compiles(C [[
    #include <float.h>

    int main(void)
    {
      unsigned int fpu_oldcw, fpu_cw;
      volatile double result;
      double a = 2877.0;
      volatile double b = 1000000.0;

      _controlfp_s(&fpu_cw, 0, 0);
      fpu_oldcw = fpu_cw;
      _controlfp_s(&fpu_cw, _PC_53, _MCW_PC);
      result = a / b;
      _controlfp_s(&fpu_cw, fpu_oldcw, _MCW_PC);
      (void)result;

      return 0;
    }
  ]] HAVE__CONTROLFP_S)
  if(HAVE__CONTROLFP_S)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()

  message(
    CHECK_START
    "Checking whether FPU control word can be manipulated by inline assembler"
  )
  check_source_compiles(C [[
    int main(void)
    {
      unsigned int oldcw, cw;
      volatile double result;
      double a = 2877.0;
      volatile double b = 1000000.0;

      __asm__ __volatile__ ("fnstcw %0" : "=m" (*&oldcw));
      cw = (oldcw & ~0x0 & ~0x300) | 0x200;
      __asm__ __volatile__ ("fldcw %0" : : "m" (*&cw));
      result = a / b;
      __asm__ __volatile__ ("fldcw %0" : : "m" (*&oldcw));
      (void)result;

      return 0;
    }
    ]] HAVE_FPU_INLINE_ASM_X86)
  if(HAVE_FPU_INLINE_ASM_X86)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
cmake_pop_check_state()
