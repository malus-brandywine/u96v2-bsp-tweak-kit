#!/bin/sh

# Description and usage

SCRIPT_DESCR="\n
The script '$(basename $0)' configures the Petainux project to 'Keep' or 'Drop' components'\n
temporary workspaces.\n\n
Usage: \n\n
$0 'path_to_petalinux_project' 'cmd'\n
\n
where 'cmd' takes values 'Keep' or 'Drop'\n
"

PETALINUX_PROJ=$1
# Values are "Keep" or "Drop"
SWITCH=$2

if [ -z $PETALINUX_PROJ ] || [ -z $SWITCH ]
then
    echo $SCRIPT_DESCR
    return 1
fi

if [ ! -d $PETALINUX_PROJ ]
then
    echo "\nDirectory " $PETALINUX_PROJ " doesn't exists\n"
    return 1
fi

CONF_FILE=${PETALINUX_PROJ}/build/conf/local.conf

if [ ! -f $CONF_FILE ]
then
    echo "\nFile " ${CONF_FILE} " doesn't exist!\n"
    return 1
fi


PROMPT="\nSetting Yocto project to "

case "$SWITCH"  in

    "Keep" )
        # Comment INHERIT += "rm_work"
        echo "${PROMPT}\"Keep\" temporary workspaces\n"
        sed -i 's/\(^INHERIT += "rm_work"\)/#\1/' ${CONF_FILE}
        ;;

    "Drop" )
         # Uncomment INHERIT += "rm_work"
        echo "${PROMPT}\"Drop\" temporary workspaces\n"
        sed -i 's/\(^#INHERIT += "rm_work"\)/INHERIT += "rm_work"/' ${CONF_FILE}
        ;;
        
    *)
        echo "\nPlease specify \"Keep\" or \"Drop\" components' temporary workspaces \n"
        ;;

esac
   
echo "Done."
