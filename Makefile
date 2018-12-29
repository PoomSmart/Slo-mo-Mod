PACKAGE_VERSION = 1.5.6a

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = SlalomEnabler
SUBPROJECTS = SlalomEnableriOS7 SlalomEnableriOS8 SlalomEnableriOS9 SlalomEnableriOS10 SlalomEnabler SlalomPref

include $(THEOS_MAKE_PATH)/aggregate.mk

LIBRARY_NAME = SlalomShared
SlalomShared_FILES = SlalomMBProgressHUD.m SlalomUtilities.m SlalomHelper.m
SlalomShared_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries/SlalomEnabler

include $(THEOS_MAKE_PATH)/library.mk
