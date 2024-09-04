DESCRIPTION = "Image definition for Ultra96V2 board experiment project"
LICENSE = "MIT"

inherit core-image

# for a debug setting:
IMAGE_FEATURES:append = "serial-autologin-root debug-tweaks"

