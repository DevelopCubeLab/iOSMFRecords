TARGET := iphone:clang:latest:7.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MFRecordPlus

MFRecordPlus_FILES = Tweak.x
MFRecordPlus_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-stage::
	@echo "Copying .dylib to parent directory..."
	cp $(THEOS_STAGING_DIR)/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).dylib ../$(TWEAK_NAME)/
	@echo "Copy completed."
