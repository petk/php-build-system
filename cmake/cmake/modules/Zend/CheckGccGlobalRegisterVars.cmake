#[=============================================================================[
Checks for global register variables support.

Module sets the following variables:

HAVE_GCC_GLOBAL_REGS
  Set to 1 if the target system has support for global register variables.
]=============================================================================]#

include(CheckCSourceCompiles)

function(_php_check_gcc_global_register_vars)
  message(STATUS "Checking for global register variables support")

  check_c_source_compiles("
    #if defined(__GNUC__)
    # define ZEND_GCC_VERSION (__GNUC__ * 1000 + __GNUC_MINOR__)
    #else
    # define ZEND_GCC_VERSION 0
    #endif
    #if defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(i386)
    # define ZEND_VM_FP_GLOBAL_REG \"%esi\"
    # define ZEND_VM_IP_GLOBAL_REG \"%edi\"
    #elif defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(__x86_64__)
    # define ZEND_VM_FP_GLOBAL_REG \"%r14\"
    # define ZEND_VM_IP_GLOBAL_REG \"%r15\"
    #elif defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(__powerpc64__)
    # define ZEND_VM_FP_GLOBAL_REG \"r28\"
    # define ZEND_VM_IP_GLOBAL_REG \"r29\"
    #elif defined(__IBMC__) && ZEND_GCC_VERSION >= 4002 && defined(__powerpc64__)
    # define ZEND_VM_FP_GLOBAL_REG \"r28\"
    # define ZEND_VM_IP_GLOBAL_REG \"r29\"
    #elif defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(__aarch64__)
    # define ZEND_VM_FP_GLOBAL_REG \"x27\"
    # define ZEND_VM_IP_GLOBAL_REG \"x28\"
    #elif defined(__GNUC__) && ZEND_GCC_VERSION >= 4008 && defined(__riscv) && __riscv_xlen == 64
    # define ZEND_VM_FP_GLOBAL_REG \"x18\"
    # define ZEND_VM_IP_GLOBAL_REG \"x19\"
    #else
    # error \"global register variables are not supported\"
    #endif

    typedef int (*opcode_handler_t)(void);
    register void *FP  __asm__(ZEND_VM_FP_GLOBAL_REG);
    register const opcode_handler_t *IP __asm__(ZEND_VM_IP_GLOBAL_REG);

    int emu(const opcode_handler_t *ip, void *fp) {
      const opcode_handler_t *orig_ip = IP;
      void *orig_fp = FP;
      IP = ip;
      FP = fp;
      while ((*ip)());
      FP = orig_fp;
      IP = orig_ip;
    }

    int main(void) {
      return 0;
    }
  " HAVE_GCC_GLOBAL_REGS)
endfunction()

_php_check_gcc_global_register_vars()
