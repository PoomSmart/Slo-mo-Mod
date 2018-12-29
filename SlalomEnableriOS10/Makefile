TARGET = iphone:clang:latest:8.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = SlalomEnableriOS10
SlalomEnableriOS10_FILES = Tweak.xm
SlalomEnableriOS10_FRAMEWORKS = AVFoundation CoreMedia UIKit
SlalomEnableriOS10_EXTRA_FRAMEWORKS = CydiaSubstrate
SlalomEnableriOS10_LIBRARIES = MobileGestalt
SlalomEnableriOS10_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk
