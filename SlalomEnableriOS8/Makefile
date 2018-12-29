TARGET = iphone:clang:latest:8.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = SlalomEnableriOS8
SlalomEnableriOS8_FILES = Tweak.xm
SlalomEnableriOS8_FRAMEWORKS = AVFoundation CoreMedia UIKit
SlalomEnableriOS8_EXTRA_FRAMEWORKS = CydiaSubstrate
SlalomEnableriOS8_LIBRARIES = MobileGestalt
SlalomEnableriOS8_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk
