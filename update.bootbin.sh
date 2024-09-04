#!/bin/sh

# The script builds boot image BOOT.BIN that contains bistream image.

# Bitstream is taken from pre-built directory

PETALINUX_PROJ=$1

if [ -z $PETALINUX_PROJ ]
then
    echo "Please set a path to the project as a parameter\n"
    return 1
fi

petalinux-package -p ${PETALINUX_PROJ} --boot \
--fsbl ${PETALINUX_PROJ}/images/linux/zynqmp_fsbl.elf \
--fpga ${PETALINUX_PROJ}/pre-built/linux/images/system.bit \
--dtb ${PETALINUX_PROJ}/images/linux/system.dtb \
--u-boot ${PETALINUX_PROJ}/images/linux/u-boot.elf \
--force


#--fsbl <FSBL_ELF>           For ZynqMP: Default is images/linux/zynqmp_fsbl.elf
#--fpga <BITSTREAM>          Default is: images/linux/*.bit (The one copied from the HDF)
#--dtb [<DTB_IMG>]
#--pmufw [<PMUFW_ELF>]       Default is: <PROJECT>/images/linux/pmufw.elf
#--kernel [<KERNEL_ING>]     Default: <PROJECT>/images/linux/image.ub
#--u-boot [<U_BOOT_IMG>]     For Zynq:
#                                * path to the u-boot ELF image
#                                  default: <PROJECT>/images/linux/u-boot.elf

