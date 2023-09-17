#[=============================================================================[
Check which gethostbyname_r() function should be used.

The gethostbyname_r() function has different signatures on different systems.

See https://github.com/autoconf-archive/autoconf-archive/blob/master/m4/ax_func_which_gethostbyname_r.m4

If successful the module sets the following variables:

HAVE_GETHOSTBYNAME_R
  Set to 1 if gethostbyname_r() is available.

HAVE_FUNC_GETHOSTBYNAME_R_3
  Set to 1 if function has 3 arguments.

HAVE_FUNC_GETHOSTBYNAME_R_5
  Set to 1 if function has 5 arguments.

HAVE_FUNC_GETHOSTBYNAME_R_6
  Set to 1 if function has 6 arguments.
]=============================================================================]#

include(CheckCSourceCompiles)

message(STATUS "Checking how many arguments gethostbyname_r() takes")

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
" _have_6_arguments)

# Check for 5 arguments signature.
if(NOT _have_6_arguments)
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
  " _have_5_arguments)
endif()

# Check for 3 arguments signature.
if(NOT _have_6_arguments AND NOT _have_5_arguments)
  check_c_source_compiles("
    #include <netdb.h>

    int main(void) {
      char *name = \"www.gnu.org\";
      struct hostent ret;
      struct hostent_data data;
      (void)gethostbyname_r(name, &ret, &data);

      return 0;
    }
  " _have_3_arguments)
endif()

if(_have_3_arguments OR _have_5_arguments OR _have_6_arguments)
  set(HAVE_GETHOSTBYNAME_R 1 CACHE INTERNAL "Define to 1 if you have some form of gethostbyname_r().")
endif()

if(_have_3_arguments)
  set(HAVE_FUNC_GETHOSTBYNAME_R_3 1 CACHE INTERNAL "Define to 1 if you have the three-argument form of gethostbyname_r().")
  message(STATUS "3")
elseif(_have_5_arguments)
  set(HAVE_FUNC_GETHOSTBYNAME_R_5 1 CACHE INTERNAL "Define to 1 if you have the five-argument form of gethostbyname_r().")
  message(STATUS "five")
elseif(_have_6_arguments)
  set(HAVE_FUNC_GETHOSTBYNAME_R_6 1 CACHE INTERNAL "Define to 1 if you have the six-argument form of gethostbyname_r().")
  message(STATUS "six")
else()
  message(WARNING "can't tell")
endif()
