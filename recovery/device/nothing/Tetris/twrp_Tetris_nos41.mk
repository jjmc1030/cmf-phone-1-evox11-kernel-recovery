# Nothing OS 4.1 recovery product.  It inherits the common Tetris recovery
# userspace while selecting the ROM-specific runtime module profile in
# BoardConfig.mk.
$(call inherit-product, device/nothing/Tetris/twrp_Tetris.mk)

PRODUCT_NAME := twrp_Tetris_nos41
