TARGET = iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = SlalomEnableriOS7
SlalomEnableriOS7_FILES = Tweak.xm
SlalomEnableriOS7_FRAMEWORKS = AVFoundation CoreMedia UIKit
SlalomEnableriOS7_EXTRA_FRAMEWORKS = CydiaSubstrate
SlalomEnableriOS7_LIBRARIES = MobileGestalt
SlalomEnableriOS7_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk
