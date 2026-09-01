#
# OrangeFox 16 device configuration for the CMF Phone 1 (Tetris).
# Based on the Evolution X 11.10 Android 16 vendor_boot layout and the
# hardware configuration proven by the working TWRP touch-fix v4 image.
#

DEVICE_PATH := device/nothing/Tetris
KERNEL_PATH := device/nothing/Tetris-kernel

# The minimal TWRP manifest intentionally omits non-recovery components.
ALLOW_MISSING_DEPENDENCIES := true

# A/B and dynamic partitions
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    init_boot \
    odm \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_boot \
    vendor_dlkm

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a76
TARGET_CPU_VARIANT_RUNTIME := cortex-a76
IGNORE_PREFER32_ON_DEVICE := true

# APEX
OVERRIDE_TARGET_FLATTEN_APEX := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := Tetris
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_HEIGHT := 2400
TARGET_SCREEN_WIDTH := 1080
TARGET_SCREEN_DENSITY := 420

# Kernel and vendor_boot. These values match Evolution X 11.10 exactly.
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_SOURCE := $(KERNEL_PATH)/kernel-headers
TARGET_PREBUILT_KERNEL := $(KERNEL_PATH)/Image
TARGET_FORCE_PREBUILT_KERNEL := true
BOARD_KERNEL_IMAGE_NAME := Image

BOARD_BOOT_HEADER_VERSION := 4
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_BASE := 0x3fff8000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x26f08000
BOARD_KERNEL_TAGS_OFFSET := 0x07c88000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_DTB_OFFSET := 0x1bf8040
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_RAMDISK_USE_LZ4 := true
BOARD_KERNEL_SEPARATED_DTBO := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true

BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2
BOARD_KERNEL_CMDLINE += rcu_nocbs=all rcutree.enable_rcu_lazy=1
BOARD_BOOTCONFIG += androidboot.init_fatal_reboot_target=recovery

BOARD_MKBOOTIMG_ARGS += --base $(BOARD_KERNEL_BASE)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

BOARD_PREBUILT_DTBIMAGE_DIR := $(KERNEL_PATH)/dtbs
TARGET_PREBUILT_DTB := $(KERNEL_PATH)/dtbs/mt6878.dtb
BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PATH)/dtbo.img

# Exact Evolution X vendor_boot modules. The final image also preserves the
# original platform ramdisk, so Wi-Fi and other vendor module sets stay intact.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(KERNEL_PATH)/vendor_boot/modules.load))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(sort $(addprefix $(KERNEL_PATH)/vendor_boot/, $(notdir $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD))))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(KERNEL_PATH)/vendor_boot/modules.load.recovery))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES := $(sort $(addprefix $(KERNEL_PATH)/vendor_boot/, $(notdir $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD))))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES += $(filter-out $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES),$(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES))

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608

BOARD_SUPER_PARTITION_GROUPS := main
BOARD_SUPER_PARTITION_SIZE := 9663676416
BOARD_MAIN_SIZE := 9122611200
BOARD_MAIN_PARTITION_LIST := odm odm_dlkm product system system_dlkm system_ext vendor vendor_dlkm

TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USES_METADATA_PARTITION := true
BOARD_ROOT_EXTRA_FOLDERS += metadata

# Platform
BOARD_HAS_MTK_HARDWARE := true
BOARD_USES_MTK_HARDWARE := true
TARGET_BOARD_PLATFORM := mt6878

# Recovery lives in the header-v4 recovery fragment of vendor_boot.
BOARD_USES_RECOVERY_AS_BOOT := false
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/recovery.fstab
ifeq ($(TARGET_PRODUCT),twrp_Tetris_nos41)
# Keep Evolution X on its common Health declaration while Nothing OS 4.1 uses
# the Health v2 service exposed by its exact vendor stack.
TARGET_RECOVERY_DEVICE_DIRS := $(DEVICE_PATH) $(DEVICE_PATH)/nothingos41
endif
# The recovery fstab contains the Nothing OS 4.1 Android 16 metadata-FBE
# flags. Re-parsing a mounted vendor copy caused the v1 recovery process to
# block at "Using additional fstab for decryption" and init then restarted it.
TW_SKIP_ADDITIONAL_FSTAB := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_USERIMAGES_USE_F2FS := true

# Build the native Android 16 KeyMint, GateKeeper, Keystore2, and metadata-FBE
# stack. The recovery ramdisk starts the ROM-matched Trustonic services in the
# background before this path unwraps the metadata key.
TW_INCLUDE_CRYPTO := true
TW_USE_FSCRYPT_POLICY := 2

# Evolution X's Tetris recovery uses the AIDL boot-control service.  Make both
# update_engine_sideload and OrangeFox's slot selector use that same interface.
OF_USE_AIDL_BOOT_CONTROL := 1

# Recreate the correct user-0 media path after Format Data and rebuild the MTP
# export around it.  Without this, MTP can retain /data/media as its backing
# directory while OrangeFox browses /data/media/0.
OF_BIND_MOUNT_SDCARD_ON_FORMAT := 1

# Security levels from the supplied Evolution X images.
PLATFORM_SECURITY_PATCH := 2026-08-01
VENDOR_SECURITY_PATCH := 2025-02-08
PLATFORM_VERSION := 16.1.0

# Verified Boot. Evolution X uses the standard AOSP RSA-2048 test key.
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_ALGORITHM := SHA256_RSA2048
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_ROLLBACK_INDEX := 0
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true
BOARD_AVB_VENDOR_BOOT_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_VENDOR_BOOT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX := 0
BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX_LOCATION := 6

# OrangeFox/TWRP UI and recovery tools
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := false
# The RTC already carries the correct Unix epoch on this MediaTek device.  Use
# the phone owner's local timezone instead of OrangeFox's Central-European
# default so the displayed clock matches Android without applying a time drift.
OF_DEFAULT_TIMEZONE := PHT-8
OF_FORCE_TIMEZONE := PHT-8
# OrangeFox's Android 16 tree keys these features with the TWRP_INCLUDE_LOGCAT
# and TARGET_USES_LOGD names.  The older aliases silently omitted logd from
# the recovery ramdisk, hiding Keystore2's metadata-decryption diagnostics.
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_PYTHON := false
TW_USE_TOOLBOX := true
# Recovery links against Magisk's resetprop library when repack tools are
# enabled; explicitly retain it in the recovery ramdisk.
TW_RECOVERY_ADDITIONAL_RELINK_LIBRARY_FILES += $(TARGET_OUT_SHARED_LIBRARIES)/libresetprop.so
TW_MAX_BRIGHTNESS := 2047
TW_CUSTOM_BATTERY_PATH := /sys/class/power_supply/battery
TW_USE_LEGACY_BATTERY_SERVICES := true
TW_INPUT_BLACKLIST := hbtp_vm
TW_Y_OFFSET := 95
TW_H_OFFSET := -95
TW_NO_SCREEN_BLANK := true

# Load the exact recovery subset from the preserved vendor_boot platform ramdisk.
# The FocalTech touchscreen lives in vendor_dlkm rather than vendor_boot, so it
# is not part of Android's early recovery module set. Request the ROM-matched
# driver, its vendor_dlkm dependencies, and bootinfo's charger dependencies
# explicitly. TWRP mounts vendor_dlkm before starting the UI; all other display
# and charger-class dependencies are already loaded by first-stage init.
# The touchscreen's vendor_dlkm bootinfo module imports four charger-info
# symbols.  Their providers live in the Nothing OS vendor_boot module tree,
# outside modules.load.recovery, so they must be requested explicitly before
# bootinfo and focaltech_tp.  A live v4 test confirmed this exact dependency
# order by creating the missing fts_ts input device after loading the four
# providers.
TETRIS_RECOVERY_PROVIDER_MODULES := \
    sc8541_charger.ko \
    upm6720_charger.ko \
    nu2115_charger.ko \
    sgm41606S_charger.ko
TETRIS_RECOVERY_TOUCH_MODULES := \
    bootinfo.ko \
    touchpanel_event_notify.ko \
    focaltech_tp.ko
TW_LOAD_VENDOR_MODULES_EXCLUDE_GKI := true
TW_LOAD_VENDOR_BOOT_MODULES := true
# Keep the driver list as one quoted compiler definition. Without the literal
# quotes, every filename after the first is treated as a separate clang input.
# Do not sort the provider prefix: bootinfo imports one symbol from each of
# these four modules.  Load them first, then the normal sorted recovery set.
TETRIS_RECOVERY_SORTED_MODULES := $(filter-out $(TETRIS_RECOVERY_PROVIDER_MODULES),$(sort $(notdir $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD)) $(TETRIS_RECOVERY_TOUCH_MODULES)))
TW_LOAD_VENDOR_MODULES := $(shell echo \"$(TETRIS_RECOVERY_PROVIDER_MODULES) $(TETRIS_RECOVERY_SORTED_MODULES)\")
