#[=============================================================================[
Check which gethostbyname_r() function should be used.

The gethostbyname_r() function has different signatures on different systems.

See https://github.com/autoconf-archive/autoconf-archive/blob/master/m4/ax_func_which_gethostbyname_r.m4

Cache variables:

  HAVE_GETHOSTBYNAME_R
    Whether gethostbyname_r() is available.
  HAVE_FUNC_GETHOSTBYNAME_R_3
    Whether function has 3 arguments.
  HAVE_FUNC_GETHOSTBYNAME_R_5
    Whether function has 5 arguments.
  HAVE_FUNC_GETHOSTBYNAME_R_6
    Whether function has 6 arguments.
]=============================================================================]#

include_guard(GLOBAL)

include(CheckCSourceCompiles)

message(CHECK_START "Checking how many arguments gethostbyname_r() takes")

list(APPEND CMAKE_MESSAGE_INDENT "  ")

# Sanity check with 1 argument signature.
check_c_source_compiles("
  #include <netdb.h>

  int main(void) {
    char *name = \"www.gnu.org\";
    (void)gethostbyname_r(name);

    return 0;
  }
" _have_one_argument)

if(_have_one_argument)
  list(POP_BACK CMAKE_MESSAGE_INDENT)
  message(CHECK_FAIL "can't tell")
  message(WARNING "Cannot find function declaration in netdb.h")
  return()
endif()

# Check for 6 arguments signature.
check_c_source_compiles("
  #include <netdb.h>

  int main(void) {
    char *name = \"www.gnu.org\";
    struct hostent ret, *retp;
    char buf[1024];
    int buflen = 1024;
    int my_h_errno;
    (void)gethostbyname_r(name, &ret, buf, buflen, &retp, &my_h_errno);

    return 0;
  }
" HAVE_FUNC_GETHOSTBYNAME_R_6)

# Check for 5 arguments signature.
if(NOT HAVE_FUNC_GETHOSTBYNAME_R_6)
  check_c_source_compiles("
    #include <netdb.h>

    int main(void) {
      char *name = \"www.gnu.org\";
      struct hostent ret;
      char buf[1024];
      int buflen = 1024;
      int my_h_errno;
      (void)gethostbyname_r(name, &ret, buf, buflen, &my_h_errno);

      return 0;
    }
  " HAVE_FUNC_GETHOSTBYNAME_R_5)
endif()

# Check for 3 arguments signature.
if(NOT HAVE_FUNC_GETHOSTBYNAME_R_6 AND NOT HAVE_FUNC_GETHOSTBYNAME_R_5)
  check_c_source_compiles("
    #include <netdb.h>

    int main(void) {
      char *name = \"www.gnu.org\";
      struct hostent ret;
      struct hostent_data data;
      (void)gethostbyname_r(name, &ret, &data);

      return 0;
    }
  " HAVE_FUNC_GETHOSTBYNAME_R_3)
endif()

if(
  HAVE_FUNC_GETHOSTBYNAME_R_3
  OR HAVE_FUNC_GETHOSTBYNAME_R_5
  OR HAVE_FUNC_GETHOSTBYNAME_R_6
)
  set(
    HAVE_GETHOSTBYNAME_R 1
    CACHE INTERNAL "Define to 1 if you have some form of gethostbyname_r()."
  )
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)

if(HAVE_FUNC_GETHOSTBYNAME_R_3)
  message(CHECK_PASS "three")
elseif(HAVE_FUNC_GETHOSTBYNAME_R_5)
  message(CHECK_PASS "five")
elseif(HAVE_FUNC_GETHOSTBYNAME_R_6)
  message(CHECK_PASS "six")
else()
  message(CHECK_FAIL "can't tell")
endif()
