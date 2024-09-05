#!/bin/sh
# Description and usage

SCRIPT_DESCR="\n
The script '$(basename $0)' tweaks configuration parameters in '/project-spec/configs/config'\n
to build an image for loading into RAM.\n\n
Usage: \n\n
$0 'path_to_petalinux_project'\n
\n
"

PETALINUX_BOARD_NAME=u96v2_sbc
PETALINUX_BOARD_FAMILY=u96v2
INITRAMFS_IMAGE="u96v2exp-image-core"

PLNX_PROJ=$1

if [ -z $PLNX_PROJ ]
then
    echo $SCRIPT_DESCR
    return 1
fi

if [ ! -d $PLNX_PROJ ]
then
    echo "\nDirectory " $PLNX_PROJ " doesn't exists\n"
    return 1
fi

echo "\n
Board name: ${PETALINUX_BOARD_NAME}
Board Family: ${PETALINUX_BOARD_FAMILY}
InitRAMFS image recipe: ${INITRAMFS_IMAGE}\n\n"

echo "Setting Boot Method to INITRD ...\n\n"

export PLNX_PROJ

./config.boot_method.INITRD.sh ${PETALINUX_BOARD_NAME} ${PETALINUX_BOARD_FAMILY} ${INITRAMFS_IMAGE}

echo "Done."
