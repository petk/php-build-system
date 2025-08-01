#[=============================================================================[
Check whether the compiler and target system support global register variables.
Global register variables are relevant for the GNU C compatible compilers.
See also https://gcc.gnu.org/onlinedocs/gcc/Global-Register-Variables.html

Result variables:

* HAVE_GCC_GLOBAL_REGS
#]=============================================================================]

include(CheckSourceCompiles)
include(CMakePushCheckState)

set(HAVE_GCC_GLOBAL_REGS FALSE)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  return()
endif()

option(ZEND_GLOBAL_REGISTER_VARIABLES "Enable global register variables" ON)
mark_as_advanced(ZEND_GLOBAL_REGISTER_VARIABLES)

if(NOT ZEND_GLOBAL_REGISTER_VARIABLES)
  return()
endif()

# Skip in consecutive configuration phases.
if(NOT DEFINED PHP_ZEND_HAS_GCC_GLOBAL_REGS)
  message(CHECK_START "Checking for global register variables support")

  cmake_push_check_state(RESET)
    set(CMAKE_REQUIRED_QUIET TRUE)

    check_source_compiles(C [[
      #if defined(__GNUC__)
      # define ZEND_GCC_VERSION (__GNUC__ * 1000 + __GNUC_MINOR__)
      #else
      # define ZEND_GCC_VERSION 0
      #endif
      #if defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(i386)
      # define ZEND_VM_FP_GLOBAL_REG "%esi"
      # define ZEND_VM_IP_GLOBAL_REG "%edi"
      #elif defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(__x86_64__)
      # define ZEND_VM_FP_GLOBAL_REG "%r14"
      # define ZEND_VM_IP_GLOBAL_REG "%r15"
      #elif defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(__powerpc64__)
      # define ZEND_VM_FP_GLOBAL_REG "r28"
      # define ZEND_VM_IP_GLOBAL_REG "r29"
      #elif defined(__IBMC__) && ZEND_GCC_VERSION >= 4002 && defined(__powerpc64__)
      # define ZEND_VM_FP_GLOBAL_REG "r28"
      # define ZEND_VM_IP_GLOBAL_REG "r29"
      #elif defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(__aarch64__)
      # define ZEND_VM_FP_GLOBAL_REG "x27"
      # define ZEND_VM_IP_GLOBAL_REG "x28"
      #elif defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(__riscv) && __riscv_xlen == 64
      # define ZEND_VM_FP_GLOBAL_REG "x18"
      # define ZEND_VM_IP_GLOBAL_REG "x19"
      #else
      # error "global register variables are not supported"
      #endif

      typedef int (*opcode_handler_t)(void);
      register void *FP  __asm__(ZEND_VM_FP_GLOBAL_REG);
      register const opcode_handler_t *IP __asm__(ZEND_VM_IP_GLOBAL_REG);

      int emu(const opcode_handler_t *ip, void *fp)
      {
        const opcode_handler_t *orig_ip = IP;
        void *orig_fp = FP;
        IP = ip;
        FP = fp;
        while ((*ip)());
        FP = orig_fp;
        IP = orig_ip;
      }

      int main(void)
      {
        return 0;
      }
    ]] PHP_ZEND_HAS_GCC_GLOBAL_REGS)
  cmake_pop_check_state()

  if(PHP_ZEND_HAS_GCC_GLOBAL_REGS)
    message(CHECK_PASS "yes")
  else()
    message(CHECK_FAIL "no")
  endif()
endif()

set(HAVE_GCC_GLOBAL_REGS ${PHP_ZEND_HAS_GCC_GLOBAL_REGS})
