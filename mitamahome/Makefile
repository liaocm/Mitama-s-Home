INSTALL_TARGET_PROCESSES = madomagi Preferences

export SDKVERSION = 13.0

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2223

ARCHS = arm64

include $(THEOS)/makefiles/common.mk
$(call $(shell python3 gencode.py))

TWEAK_NAME = MitamaHome

MitamaHome_FILES = Tweak.xm

MitamaHome_FILES += $(wildcard src/*.m src/*.mm src/*/*.m src/*/*.mm)

MitamaHome_CFLAGS = -fobjc-arc -DMITAMA_THEOS_BUILD -Iinclude -Isrc -Isrc/control -Isrc/console -Isrc/autoplay -Isrc/advanced -Isrc/quick-preference -Isrc/utils -Isrc/webview
MitamaHome_EXTRA_FRAMEWORKS = PTFakeTouch
MitamaHome_FRAMEWORKS = IOKit WebKit
MitamaHome_PRIVATE_FRAMEWORKS = AppSupport
MitamaHome_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += mitamapref
include $(THEOS_MAKE_PATH)/aggregate.mk
