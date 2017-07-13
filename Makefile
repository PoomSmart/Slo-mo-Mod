GO_EASY_ON_ME = 1
TARGET = iphone:latest:7.0
PACKAGE_VERSION = 1.5.3

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = SlalomEnabler
SUBPROJECTS = SlalomEnableriOS7 SlalomEnableriOS8 SlalomEnableriOS9 SlalomEnableriOS10

include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = SlalomEnabler
SlalomEnabler_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = SlalomModSettings
SlalomModSettings_FILES = SlalomModPreferenceController.m SlalomMBProgressHUD.m
SlalomModSettings_INSTALL_PATH = /Library/PreferenceBundles
SlalomModSettings_FRAMEWORKS = AVFoundation CoreGraphics Social UIKit
SlalomModSettings_PRIVATE_FRAMEWORKS = Preferences
SlalomModSettings_LIBRARIES = cepheiprefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Sla.plist$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
