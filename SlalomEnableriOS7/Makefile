GO_EASY_ON_ME = 1
SDKVERSION = 7.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = SlalomEnableriOS7
SlalomEnableriOS7_FILES = Tweak.xm ../SlalomMBProgressHUD.m
SlalomEnableriOS7_FRAMEWORKS = AVFoundation CoreGraphics CoreMedia QuartzCore UIKit
SlalomEnableriOS7_PRIVATE_FRAMEWORKS = PhotoLibrary
SlalomEnableriOS7_LIBRARIES = MobileGestalt substrate
SlalomEnableriOS7_INSTALL_PATH = /Library/Application Support/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk
