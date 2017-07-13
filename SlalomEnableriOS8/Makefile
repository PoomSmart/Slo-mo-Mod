GO_EASY_ON_ME = 1
SDKVERSION = 8.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = SlalomEnableriOS8
SlalomEnableriOS8_FILES = Tweak.xm ../SlalomMBProgressHUD.m
SlalomEnableriOS8_FRAMEWORKS = AVFoundation CoreGraphics CoreMedia QuartzCore UIKit
SlalomEnableriOS8_PRIVATE_FRAMEWORKS = PhotoLibrary
SlalomEnableriOS8_LIBRARIES = MobileGestalt substrate
SlalomEnableriOS8_INSTALL_PATH = /Library/Application Support/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk
