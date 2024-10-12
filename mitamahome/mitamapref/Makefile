include $(THEOS)/makefiles/common.mk

ARCHS = arm64e arm64

BUNDLE_NAME = mitamapref

mitamapref_FILES = MTMRootListController.m
mitamapref_INSTALL_PATH = /Library/PreferenceBundles
mitamapref_FRAMEWORKS = UIKit
mitamapref_PRIVATE_FRAMEWORKS = Preferences
mitamapref_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/mitamapref.plist$(ECHO_END)
