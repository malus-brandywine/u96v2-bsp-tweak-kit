#!/bin/sh

# The script builds boot image BOOT.BIN that contains bistream image.
# Bitstream is taken from pre-built directory

SCRIPT_DESCR="\n
The script '$(basename $0)' updates boot image BOOT.BIN\n\n
It picks 'system.bit' from the project's pre-built directory,\n
other files are taken from Deploy Directory:\n
\${path_to_petalinux_project}/images/linux or\n
\${path_to_petalinux_project}/images/linux/\${suffix}, if 'suffix' is present\n\n
BOOT.BIN is placed back in the Deploy Directory\n\n
Usage: \n\n
$0 'path_to_petalinux_project' [suffix]\n
"

PETALINUX_PROJ=$1
SUFFIX=$2


if [ -z $PETALINUX_PROJ ]
then
    echo $SCRIPT_DESCR
    return 1
fi


if [ ! -d $PETALINUX_PROJ ]
then
    echo "\nDirectory " $PETALINUX_PROJ " doesn't exists\n"
    return 1
fi


if [ -z $SUFFIX ]
then
    DEPLOY_DIR="${PETALINUX_PROJ}/images/linux"
else
    DEPLOY_DIR="${PETALINUX_PROJ}/images/linux/${SUFFIX}"
fi


if [ ! -d $DEPLOY_DIR ]
then
    echo "\nDirectory " ${DEPLOY_DIR} " doesn't exist!\n"
    return 1
fi


echo "\nDeploy Directory: ${DEPLOY_DIR}\n"


petalinux-package -p ${PETALINUX_PROJ} --boot \
--fsbl ${DEPLOY_DIR}/zynqmp_fsbl.elf \
--fpga ${PETALINUX_PROJ}/pre-built/linux/images/system.bit \
--dtb ${DEPLOY_DIR}/system.dtb \
--atf ${DEPLOY_DIR}/bl31.elf \
--pmufw ${DEPLOY_DIR}/pmufw.elf \
--u-boot ${DEPLOY_DIR}/u-boot.elf \
--force

