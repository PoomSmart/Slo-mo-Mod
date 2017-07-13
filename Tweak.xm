#import "../PS.h"
#import <dlfcn.h>

%ctor {
    if (isiOS10Up)
        dlopen("/Library/Application Support/SlalomEnabler/SlalomEnableriOS10.dylib", RTLD_LAZY);
    else if (isiOS9)
        dlopen("/Library/Application Support/SlalomEnabler/SlalomEnableriOS9.dylib", RTLD_LAZY);
    else if (isiOS8)
        dlopen("/Library/Application Support/SlalomEnabler/SlalomEnableriOS8.dylib", RTLD_LAZY);
    else if (isiOS7)
        dlopen("/Library/Application Support/SlalomEnabler/SlalomEnableriOS7.dylib", RTLD_LAZY);
}
