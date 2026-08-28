# Base Android 16 recovery product
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Virtual A/B with the recovery ramdisk in vendor_boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Device and OrangeFox/TWRP configuration.
$(call inherit-product, device/nothing/Tetris/device.mk)
$(call inherit-product, vendor/twrp/config/common.mk)

PRODUCT_DEVICE := Tetris
PRODUCT_NAME := twrp_Tetris
PRODUCT_BRAND := Nothing
PRODUCT_MODEL := A015
PRODUCT_MANUFACTURER := Nothing
PRODUCT_RELEASE_NAME := CMF Phone 1
