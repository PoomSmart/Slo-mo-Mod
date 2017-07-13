GO_EASY_ON_ME = 1
TARGET = iphone:9.0

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = SlalomEnableriOS10
SlalomEnableriOS10_FILES = Tweak.xm ../SlalomMBProgressHUD.m
SlalomEnableriOS10_FRAMEWORKS = AVFoundation CoreGraphics CoreMedia QuartzCore UIKit
SlalomEnableriOS10_PRIVATE_FRAMEWORKS = PhotoLibrary
SlalomEnableriOS10_LIBRARIES = MobileGestalt substrate
SlalomEnableriOS10_INSTALL_PATH = /Library/Application Support/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk
