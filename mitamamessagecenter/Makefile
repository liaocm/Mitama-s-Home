INSTALL_TARGET_PROCESSES = SpringBoard

export SDKVERSION = 13.0

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2221

include $(THEOS)/makefiles/common.mk

ARCHS = arm64e arm64

TWEAK_NAME = MitamaMessageCenter

MitamaMessageCenter_FILES = Tweak.xm MMCService.m
MitamaMessageCenter_CFLAGS = -fobjc-arc -D SPRINGBOARD=1
MitamaMessageCenter_LIBRARIES = rocketbootstrap
MitamaMessageCenter_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk
