#include <unistd.h>

int main(int argc, char *argv[])
{
    char buf[64];

    /*
    TODO: remove this comment
    Autoconf implementation uses a different return due to Autoconf's configure
    using the file descriptor 0 which results below in an error. The file
    descriptor 0 with CMake script execution is available and doesn't result in
    and error when calling ttyname_r.
    */
    return ttyname_r(0, buf, 64) ? 1 : 0;
}
