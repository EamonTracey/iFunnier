ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = iFunnierPreferences

iFunnierPreferences_FILES = $(wildcard ObjC/*.m) $(wildcard Swift/*.swift)
iFunnierPreferences_PRIVATE_FRAMEWORKS = Preferences
iFunnierPreferences_INSTALL_PATH = /Library/PreferenceBundles
iFunnierPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk