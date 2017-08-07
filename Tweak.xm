#import "../PS.h"
#import <dlfcn.h>

%ctor {
    dlopen("/Library/MobileSubstrate/DynamicLibraries/SlalomEnabler/SlalomShared.dylib", RTLD_LAZY);
    if (isiOS10Up)
        dlopen("/Library/MobileSubstrate/DynamicLibraries/SlalomEnabler/SlalomEnableriOS10.dylib", RTLD_LAZY);
    else if (isiOS9)
        dlopen("/Library/MobileSubstrate/DynamicLibraries/SlalomEnabler/SlalomEnableriOS9.dylib", RTLD_LAZY);
    else if (isiOS8)
        dlopen("/Library/MobileSubstrate/DynamicLibraries/SlalomEnabler/SlalomEnableriOS8.dylib", RTLD_LAZY);
    else
        dlopen("/Library/MobileSubstrate/DynamicLibraries/SlalomEnabler/SlalomEnableriOS7.dylib", RTLD_LAZY);
}
