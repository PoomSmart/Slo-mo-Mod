TARGET = iphone:clang:9.3:8.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = SlalomEnableriOS9
SlalomEnableriOS9_FILES = Tweak.xm
SlalomEnableriOS9_FRAMEWORKS = AVFoundation CoreMedia UIKit
SlalomEnableriOS9_EXTRA_FRAMEWORKS = CydiaSubstrate
SlalomEnableriOS9_LIBRARIES = MobileGestalt
SlalomEnableriOS9_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk
