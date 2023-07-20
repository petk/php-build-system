#include <sys/types.h>
#include <ifaddrs.h>

struct ifaddrs *interfaces;

int main ()
{
    if (!getifaddrs(&interfaces)) {
        freeifaddrs(interfaces);
    }

    return 0;
}
