#!/system/bin/sh
# This script installs apks in /system/uninstallable directory
# when the phone is first booted after the factory reset.
#
# Apks installed via this script can be uninstalled by user.
# However, uninstallation does not remove an apk from the system image.
# Furthermore, the apks are again installed after a factory reset.
#
# Apks listed in the config file /cust/config/appmanager.cfg won't
# be neither installed or managed by Application Manager.

ORIGIN_PATH=/system/apps/bootup
TARGET_PATH=/data/app

tag1=`getprop persist.lge.appman.installstart 1`
case "$tag1" in "1")
    for file in $(ls -s ${TARGET_PATH})
    do
        r=${file//[0-9]/}
	if [ -z "$r" ]
	then
            if [ "$file" -gt "50" ]
            then
                setprop persist.lge.appman.installstart 0
                break;
            fi
        fi
    done
esac

DALVIK_ORG=/data/dalvik-cache/data@app@
DALVIK_TAR=/data/dalvik-cache/system@apps@bootup@
DALVIK_EXT=@classes.dex 

tag2=`getprop persist.lge.appman.installstart 1`
case "$tag2" in
    "1")
     for file in $(ls -a ${ORIGIN_PATH})
     do
        if [ "$file" != "." -a "$file" != ".." ]
	then
		ln -s ${ORIGIN_PATH}/${file} ${TARGET_PATH}/${file}
		ln -s ${DALVIK_ORG}${file}${DALVIK_EXT} ${DALVIK_TAR}${file}${DALVIK_EXT}
	fi
     done

    #CUPSS
    custdir=`getprop ro.lge.capp_cupss.rootdir /cust`

    CONFIG_FILE=$custdir/config/appmanager.cfg

    if [ -f $CONFIG_FILE ]
    then
        for apk in $(cat $CONFIG_FILE); do
            `rm $TARGET_PATH/$apk > /dev/null`
        done
    fi

     #JB->KK FOTA case - link need case 0
     setprop persist.lge.appman.installstart 0
     ;;
     "0")
          for file in $(ls -a ${ORIGIN_PATH})
     do
        if [ "$file" != "." -a "$file" != ".." ]
	then
		if [ -f ${TARGET_PATH}/${file} ]
		then 
			ln -s ${DALVIK_ORG}${file}${DALVIK_EXT} ${DALVIK_TAR}${file}${DALVIK_EXT}
		else
			rm ${DALVIK_TAR}${file}${DALVIK_EXT}
		fi
	fi
     done
     ;;
esac

    DEVICE=`getprop ro.product.device`
    if [ "$DEVICE" == "g2" ]; then
	`/system/vendor/bin/fix_voicemate.sh`
    fi
    
    DEVICE=`getprop ro.product.device`
     CARRIER=`getprop ro.build.target_operator`


    if [ "$DEVICE" == "b1" ]; then
    if [ "$CARRIER" == "SKT" ]; then
	/system/vendor/bin/tphone.sh
    fi
    fi
exit 0
