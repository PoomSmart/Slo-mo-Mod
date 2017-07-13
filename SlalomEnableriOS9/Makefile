GO_EASY_ON_ME = 1
TARGET = iphone:9.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = SlalomEnableriOS9
SlalomEnableriOS9_FILES = Tweak.xm ../SlalomMBProgressHUD.m
SlalomEnableriOS9_FRAMEWORKS = AVFoundation CoreGraphics CoreMedia QuartzCore UIKit
SlalomEnableriOS9_PRIVATE_FRAMEWORKS = PhotoLibrary
SlalomEnableriOS9_LIBRARIES = MobileGestalt substrate
SlalomEnableriOS9_INSTALL_PATH = /Library/Application Support/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk
