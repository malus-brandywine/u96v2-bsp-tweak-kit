#!/bin/sh

PETALINUX_BOARD_NAME=u96v2_sbc
PETALINUX_BOARD_FAMILY=u96v2
INITRAMFS_IMAGE="u96v2exp-image-core"

PLNX_PROJ=$1

if [ -z $PLNX_PROJ ]
then
    echo "Please set a path to the project as a parameter\n"
    return 1
fi

if [ ! -d $PLNX_PROJ ]
then
    echo "Directory " $PLNX_PROJ " doesn't exists\n"
    return 1
fi

echo "Board name: " ${PETALINUX_BOARD_NAME} "\n"\
"Board Family: " ${PETALINUX_BOARD_FAMILY} "\n"\
"InitRAMFS image recipe: " ${INITRAMFS_IMAGE} "\n\n"

echo "Setting RootFS type to INITRD ...\n\n"

export PLNX_PROJ

./config.boot_method.INITRD.sh ${PETALINUX_BOARD_NAME} ${PETALINUX_BOARD_FAMILY} ${INITRAMFS_IMAGE}

echo "Done."
