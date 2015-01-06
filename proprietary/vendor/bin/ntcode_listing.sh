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


    OPERATOR=`getprop ro.build.target_operator GLOBAL`
    if [ $OPERATOR != GLOBAL ]; then
    	CUST=`getprop ro.lge.capp_cupss.rootdir /cust`   #/cust/VDF_COM
      
        #avoid apk overlay model
        if [ "$CUST" != /system/cust ]; then
        
            #avoid single cust model - need to check?
            if [ "$CUST" != /cust ]; then
        	
                NTCODE_LIST=`getprop persist.sys.mcc-list XXX`
                NTCODE=${NTCODE_LIST:0:3}
                
                mkdir /data/app-system
                chown system:system /data/app-system
                chmod 771 /data/app-system
    
                mkdir /data/local/etc
                chown system:system /data/local/etc
                chmod 774 /data/local/etc
    
    		CONF=$CUST/config/
    		#CONF=/data/.OP/VDF_COM/config/
                OPNAME=${CUST:6}
                
                APPPATH=/data/.OP/${OPNAME}/apps
                PROPPATH=/data/.OP/${OPNAME}/prop
    
        case "$NTCODE" in 
    	    "XXX")
    	    #Nothing to do - fail to read ntcode
    	    echo "Nothing to do"
    	    ;;
    	    *)
    	       CURRENT=`getprop ro.build.version.incremental 0`
    	       TAG2=`getprop persist.lge.appbox.ntcode 0`
    	       
	        if [ "$TAG2" != "$CURRENT" ]; then 

    	       		if [ -d ${PROPPATH}/${NTCODE} ]; then
    	           	   for file1 in $(ls ${PROPPATH}/${NTCODE}); do
    	           	    	if [ "$file1" != "." -a "$file1" != ".." ]; then
                         	 `cat ${PROPPATH}/${NTCODE}/${file1} > /data/local/etc/${file1}`
                          	fi
                 	   done
     
    	      		elif [ -d ${PROPPATH}/FFF ]; then
    	                     for file2 in $(ls ${PROPPATH}/FFF); do
    	           	          if [ "$file2" != "." -a "$file2" != ".." ]; then
                              `cat ${PROPPATH}/${NTCODE}/${file2} > /data/local/etc/${file2}`
                                 fi
                               done
               	       fi
    	       
     
    	       DATA_SYSTEM=/data/app-system
    	       
                if [ -f $CONF/ntcode_list_${NTCODE}.cfg ]; then     	       
	    	     for apk1 in $(cat $CONF/ntcode_list_${NTCODE}.cfg); do
                          `cat ${APPPATH}/${apk1} > ${DATA_SYSTEM}/${apk1}`
                          chown system:system ${DATA_SYSTEM}/${apk1}
                          chmod 644 ${DATA_SYSTEM}/${apk1}
                     done
    	       elif [ -f $CONF/ntcode_list_FFF.cfg ]; then	       
    	             for apk2 in $(cat $CONF/ntcode_list_FFF.cfg); do
                             `cat ${APPPATH}/${apk2} > ${DATA_SYSTEM}/${apk2}`
                              chown system:system ${DATA_SYSTEM}/${apk2}
                             chmod 644 ${DATA_SYSTEM}/${apk2}
                     done
    	      fi
    	      setprop persist.lge.appbox.ntcode ${CURRENT}
    	       fi 
    	    ;;
        esac
        fi
        fi
    fi
    
    PRODUCT=`getprop ro.product.name`
       if [ "$PRODUCT" == "g2_vdf_com" ]; then
	`/system/vendor/bin/ntcode_install.sh`  
    fi 


exit 0