ARCHS = arm64 arm64e

TARGET := iphone:clang:13.7:13.0
PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = iFunnier

iFunnier_FILES = $(wildcard Logos/*.x)
iFunnier_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += iFunnierPreferences
include $(THEOS_MAKE_PATH)/aggregate.mk