DEVICE_PATH := device/nothing/Tetris

# The physical device reports first_api_level 32. Keep the real launch API
# while compiling the recovery userspace from the Android 16 source base.
PRODUCT_SHIPPING_API_LEVEL := 32
PRODUCT_TARGET_VNDK_VERSION := 34

# Virtual A/B recovery and fastbootd support.
AB_OTA_UPDATER := true
PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_PACKAGES += \
    checkpoint_gc \
    fastbootd \
    otapreopt_script \
    update_engine \
    update_engine_sideload \
    update_verifier

# Use the same recovery AIDL boot-control service as Evolution X for Tetris.
# update_engine_sideload requires this service to select and activate the
# inactive slot before it can apply an A/B payload. Its device VINTF declaration
# lives in recovery/root/vendor/etc/vintf/manifest.xml; a recovery-variant VINTF
# module would incorrectly install the device fragment under system/framework.
PRODUCT_PACKAGES += \
    android.hardware.boot-service.default_recovery

# Android 16 recovery health service and battery reporting. OrangeFox's
# recovery process requests the AIDL IHealth/default service, and Evolution X
# 11.10 declares version 4. The older HIDL 2.1 recovery service never satisfies
# that request.
PRODUCT_PACKAGES += \
    android.hardware.health-service.example_recovery

# MediaTek UFS preloader-path links. The helper is a recovery-only binary and
# its init definition lives under system/etc/init so recovery init parses it.
# It exposes the payload partition name preloader_raw_{a,b} through validated
# device-mapper slices that skip the UFS boot-LUN header.
PRODUCT_PACKAGES += \
    mtk_plpath_utils

# Libraries used by the display and Android FBE/metadata decrypt paths.
TARGET_RECOVERY_DEVICE_MODULES += \
    android.hardware.graphics.common@1.0 \
    libion \
    libkeymaster4 \
    libkeymaster41 \
    libpuresoftkeymasterdevice \
    libsysutils \
    libxml2

TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += \
    $(TARGET_OUT_SHARED_LIBRARIES)/android.hardware.graphics.common@1.0.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libion.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libkeymaster4.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libkeymaster41.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libpuresoftkeymasterdevice.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libsysutils.so \
    $(TARGET_OUT_SHARED_LIBRARIES)/libxml2.so

# Recovery properties.
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
PRODUCT_PROPERTY_OVERRIDES += \
    ro.twrp.vendor_boot=true \
    persist.sys.fuse.passthrough.enable=true

PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH)
