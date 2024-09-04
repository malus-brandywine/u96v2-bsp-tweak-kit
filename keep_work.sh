#!/bin/sh

PETALINUX_PROJ=$1
# Values are "Keep" or "Drop"
SWITCH=$2

if [ -z $PETALINUX_PROJ ]
then
    echo "Please set a path to the project as a parameter\n"
    return 1
fi

CONF_FILE=${PETALINUX_PROJ}/build/conf/local.conf

if [ ! -f $CONF_FILE ]
then
    echo "File " ${CONF_FILE} " doesn't exist!\n"
    return 1

fi

if [ -z $SWITCH ]
then
    echo "Please specify \"Keep\" or \"Drop\" whether to keep 'Work' \n"
    return 1
fi

echo -n "Setting Yocto project to "

case "$SWITCH"  in

    "Keep" )
        # Comment INHERIT += "rm_work"
        echo "\"Keep\" temporary workspace\n"
        sed -i 's/\(^INHERIT += "rm_work"\)/#\1/' ${CONF_FILE}
        ;;

    "Drop" )
         # Uncomment INHERIT += "rm_work"
        echo "\"Drop\" temporary workspace\n"
        sed -i 's/\(^#INHERIT += "rm_work"\)/INHERIT += "rm_work"/' ${CONF_FILE}
        ;;
        
    *)
        echo "Please specify \"Keep\" or \"Drop\" whether to keep 'Work' \n"
        ;;

esac
   
echo "Done."
