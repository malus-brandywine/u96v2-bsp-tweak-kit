#!/bin/sh

# Description and usage

SCRIPT_DESCR="\n
The script '$(basename $0)' sets variable 'Deploy Directory' for raw built artefacts like\n
u-boot.elf, image.ub, rootfs.cpio, etc. in the project configuration files.\n\n
Usage: \n\n
$0 'path_to_petalinux_project' [suffix]\n\n
where 'suffix' is a string that represents the name of a directory\n
after \${path_to_petalinux_project}/images/linux/\n
\n
Deploy Directory name will be:\n
\${path_to_petalinux_project}/images/linux/\${suffix}, if 'suffix' is present or\n\n
\${path_to_petalinux_project}/images/linux, otherwise\n
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

KCONFIG_EDIT="${PETALINUX}/components/yocto/buildtools/sysroots/x86_64-petalinux-linux/usr/bin/kconfig-tweak"
CONFIG_FILE=${PETALINUX_PROJ}/project-spec/configs/config

PLNXCONF_FILE_SPEC=${PETALINUX_PROJ}/project-spec/configs/plnxtool.conf
PLNXCONF_FILE_BUILD=${PETALINUX_PROJ}/build/conf/plnxtool.conf


if [ -z $SUFFIX ]
then
    # for '/project-spec/configs/config' file
    CONF_NEW_DIR="\${PROOT}/images/linux"
    # for 'plnxtool.conf'-s
    PLNX_NEW_DIR="PLNX_DEPLOY_DIR = \"\${PROOT}\/images\/linux\""
else
    # for '/project-spec/configs/config' file
    CONF_NEW_DIR="\${PROOT}/images/linux/${SUFFIX}"
    # for 'plnxtool.conf'-s
    PLNX_NEW_DIR="PLNX_DEPLOY_DIR = \"\${PROOT}\/images\/linux\/${SUFFIX}\""
fi

echo "\nSetting Deploy directory to: " $CONF_NEW_DIR
echo "into: "
echo "- project-spec/configs/plnxtool.conf"
echo "- build/conf/plnxtool.conf"
echo "- project-spec/configs/config\n"

sed -i "s/\(^PLNX_DEPLOY_DIR = .*\)/${PLNX_NEW_DIR}/" ${PLNXCONF_FILE_SPEC}
sed -i "s/\(^PLNX_DEPLOY_DIR = .*\)/${PLNX_NEW_DIR}/" ${PLNXCONF_FILE_BUILD}

${KCONFIG_EDIT} --file ${CONFIG_FILE} --set-str CONFIG_PLNX_IMAGES_LOCATION "${CONF_NEW_DIR}"

echo "Done."

