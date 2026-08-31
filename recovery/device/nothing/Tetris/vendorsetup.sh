#!/bin/bash

# OrangeFox 16 build identity and vendor_boot layout.
export FOX_BUILD_DEVICE="Tetris"
export FOX_TARGET_DEVICES="Tetris,A015,tetris"
export FOX_AB_DEVICE=1
export FOX_VIRTUAL_AB_DEVICE=1
export FOX_VENDOR_BOOT_RECOVERY=1
export FOX_BUILD_TYPE="Unofficial"
export OF_MAINTAINER="CMF-Phone-1-Community"

# CMF Phone 1 display geometry.
export OF_SCREEN_H=2400
export OF_STATUS_H=95
export OF_STATUS_INDENT_LEFT=48
export OF_STATUS_INDENT_RIGHT=48
export OF_CLOCK_POS=1
export OF_ALLOW_DISABLE_NAVBAR=0
export OF_HIDE_NOTCH=1

# Non-Xiaomi Android 16 recovery behavior.
export OF_TWRP_COMPATIBILITY_MODE=1
export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
export OF_NO_MIUI_PATCH_WARNING=1
export OF_NO_ADDITIONAL_MIUI_PROPS_CHECK=1
export OF_DISABLE_MIUI_SPECIFIC_FEATURES=1
export OF_DISABLE_OTA_MENU=1

# Keep AVB and encryption policy unchanged. The build uses the ROM's hardware
# KeyMint stack only to unlock existing FBE data. Advanced Security disables
# both ADB and MTP until decryption succeeds, which makes recovery diagnostics
# and unencrypted external storage unavailable. Leave it disabled and let
# TWRP's normal encrypted-storage checks gate access to internal storage.
export OF_ADVANCED_SECURITY=0
export OF_DONT_PATCH_ENCRYPTED_DEVICE=1
export OF_KEEP_DM_VERITY=1
export OF_KEEP_FORCED_ENCRYPTION=1
export OF_FBE_METADATA_MOUNT_IGNORE=0
export OF_FIX_DECRYPTION_ON_DATA_MEDIA=1

# Vendor-boot recovery images have a strict 64 MiB partition limit. Disable
# features that are not needed for the initial hardware/decryption test.
export FOX_DRASTIC_SIZE_REDUCTION=1
export FOX_REMOVE_BASH=1
export FOX_EXCLUDE_NANO_EDITOR=1
export FOX_ENABLE_APP_MANAGER=0
export OF_FLASHLIGHT_ENABLE=0
export OF_USE_GREEN_LED=0
export FOX_DISABLE_UPDATEZIP=1
export OF_NO_REFLASH_CURRENT_ORANGEFOX=1
