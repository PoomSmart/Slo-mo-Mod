TARGET = iphone:clang:11.2:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SlalomModSettings
SlalomModSettings_FILES = SlalomModPreferenceController.m ../SlalomMBProgressHUD.m
SlalomModSettings_INSTALL_PATH = /Library/PreferenceBundles
SlalomModSettings_FRAMEWORKS = AVFoundation CoreGraphics Social UIKit
SlalomModSettings_EXTRA_FRAMEWORKS = CepheiPrefs
SlalomModSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Sla.plist$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)