TARGET = iphone:clang:latest:7.0
PACKAGE_VERSION = 1.5.5

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = SlalomEnabler
SUBPROJECTS = SlalomEnableriOS7 SlalomEnableriOS8 SlalomEnableriOS9 SlalomEnableriOS10

include $(THEOS_MAKE_PATH)/aggregate.mk

TWEAK_NAME = SlalomEnabler
SlalomEnabler_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

LIBRARY_NAME = SlalomShared
SlalomShared_FILES = SlalomMBProgressHUD.m SlalomUtilities.m SlalomHelper.m
SlalomShared_PRIVATE_FRAMEWORKS = PhotoLibrary
SlalomShared_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk

BUNDLE_NAME = SlalomModSettings
SlalomModSettings_FILES = SlalomModPreferenceController.m SlalomMBProgressHUD.m
SlalomModSettings_INSTALL_PATH = /Library/PreferenceBundles
SlalomModSettings_FRAMEWORKS = AVFoundation CoreGraphics Social UIKit
SlalomModSettings_EXTRA_FRAMEWORKS = CepheiPrefs
SlalomModSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Sla.plist$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
