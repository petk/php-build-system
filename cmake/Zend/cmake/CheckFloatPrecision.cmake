#[=============================================================================[
Check for x87 floating point internal precision control.

See: https://wiki.php.net/rfc/rounding

Result variables:

* HAVE__FPU_SETCW - Whether _FPU_SETCW is present and usable.
* HAVE_FPSETPREC - Whether fpsetprec is present and usable.
* HAVE__CONTROLFP - Whether _controlfp is present and usable.
* HAVE__CONTROLFP_S - Whether _controlfp_s is present and usable.
* HAVE_FPU_INLINE_ASM_X86 - Whether FPU control word can be manipulated by
  inline assembler.
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

# Obsolete in favor of C99 <fenv.h> functions to control FPU rounding modes.
function(_php_zend_check_fpu_setcw result)
  # Skip in consecutive configuration phases.
  if(NOT DEFINED PHP_ZEND_${result})
    message(CHECK_START "Checking for usable _FPU_SETCW")

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)

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
      ]] PHP_ZEND_${result})
    cmake_pop_check_state()

    if(PHP_ZEND_${result})
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  set(${result} ${PHP_ZEND_${result}})

  return(PROPAGATE ${result})
endfunction()

function(_php_zend_check_fpsetprec result)
  # Skip in consecutive configuration phases.
  if(NOT DEFINED PHP_ZEND_${result})
    message(CHECK_START "Checking for usable fpsetprec")

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)

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
      ]] PHP_ZEND_${result})
    cmake_pop_check_state()

    if(PHP_ZEND_${result})
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  set(${result} ${PHP_ZEND_${result}})

  return(PROPAGATE ${result})
endfunction()

function(_php_zend_check_controlfp result)
  # Skip in consecutive configuration phases.
  if(NOT DEFINED PHP_ZEND_${result})
    message(CHECK_START "Checking for usable _controlfp")

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)

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
      ]] PHP_ZEND_${result})
    cmake_pop_check_state()

    if(PHP_ZEND_${result})
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  set(${result} ${PHP_ZEND_${result}})

  return(PROPAGATE ${result})
endfunction()

function(_php_zend_check_controlfp_s result)
  # Skip in consecutive configuration phases.
  if(NOT DEFINED PHP_ZEND_${result})
    message(CHECK_START "Checking for usable _controlfp_s")

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)

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
      ]] PHP_ZEND_${result})
    cmake_pop_check_state()

    if(PHP_ZEND_${result})
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  set(${result} ${PHP_ZEND_${result}})

  return(PROPAGATE ${result})
endfunction()

function(_php_zend_check_fpu_inline_asm_x86 result)
  # Skip in consecutive configuration phases.
  if(NOT DEFINED PHP_ZEND_${result})
    message(
      CHECK_START
      "Checking whether FPU control word can be manipulated by inline assembler"
    )

    cmake_push_check_state(RESET)
      set(CMAKE_REQUIRED_QUIET TRUE)

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
      ]] PHP_ZEND_${result})
    cmake_pop_check_state()

    if(PHP_ZEND_${result})
      message(CHECK_PASS "yes")
    else()
      message(CHECK_FAIL "no")
    endif()
  endif()

  set(${result} ${PHP_ZEND_${result}})

  return(PROPAGATE ${result})
endfunction()

_php_zend_check_fpu_setcw(HAVE__FPU_SETCW)
_php_zend_check_fpsetprec(HAVE_FPSETPREC)
_php_zend_check_controlfp(HAVE__CONTROLFP)
_php_zend_check_controlfp_s(HAVE__CONTROLFP_S)
_php_zend_check_fpu_inline_asm_x86(HAVE_FPU_INLINE_ASM_X86)
