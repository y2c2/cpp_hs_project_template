#include "Lib1_stub.h"
#include <HsFFI.h>
#include <iostream>

int main(int argc, char *argv[])
{
    hs_init(&argc, &argv);
#ifdef __GLASGOW_HASKELL__
    hs_add_root(__stginit_Foo);
#endif

    std::cout << add2(2, 3) << std::endl;

    hs_exit();
    return 0;
}
