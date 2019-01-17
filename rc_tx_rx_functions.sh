function MAIN_RC_TX_RX_FUNCTION {
	echo "================== R/C TX (tty3) ==========================="
	
	# only run rctx if no cam found and rc is not disabled
	if [ "$CAM" == "0" ] && [ "$RC" != "disabled" ]; then
	    echo "R/C enabled ... we are R/C TX (Ground Pi)"
	    rctx_function
	fi
	
	echo "R/C not enabled in configfile or we are R/C RX (Air Pi)"
	
	sleep 365d
}

# runs on RX (ground pi)
function rctx_function {
    # Convert joystick config from DOS format to UNIX format
    ionice -c 3 nice dos2unix -n /boot/joyconfig.txt /tmp/rctx.h > /dev/null 2>&1
	
    echo
	
    echo Building RC ...
    
    cd /home/pi/wifibroadcast-rc
	
    if [ "$EncryptionOrRange" == "Range" ]; then
          cd /home/pi/wifibroadcast-rc
    fi

    if [ "$EncryptionOrRange" == "Encryption" ]; then
		cd /home/pi/wifibroadcast-rc-encrypted/
    fi
    
    if [ "$EncryptionOrRange" == "RangeAth9k" ]; then
        cd /home/pi/wifibroadcast-rc-Ath9k/
    fi
    
    ionice -c 3 nice gcc -lrt -lwiringPi -lpcap rctx.c -o /tmp/rctx `sdl-config --libs` `sdl-config --cflags` || {
		echo "ERROR: Could not build RC, check joyconfig.txt!"
    }
	
    # wait until video is running to make sure NICS are configured and wifibroadcast_rx_status shmem is available

    echo
    echo -n "Waiting until nics are configured ..."
    while [ ! -f /tmp/nics_configured ]; do
		sleep 0.5
		echo -n "."
    done
	
    sleep 0.5

    NICS=`ls /sys/class/net/ | nice grep -v eth0 | nice grep -v lo | nice grep -v usb | nice grep -v intwifi | nice grep -v relay | nice grep -v wifihotspot`
    	
    pause_while
	
    echo
    echo "Starting R/C TX ..."
	
    while true; do
    
    	if [ "$EncryptionOrRange" == "Range" ] || [ "$EncryptionOrRange" == "Encryption" ]; then
		nice -n -5 /tmp/rctx $NICS
		NICS=`ls /sys/class/net/ | nice grep -v eth0 | nice grep -v lo | nice grep -v usb | nice grep -v intwifi | nice grep -v relay | nice grep -v wifihotspot`
	fi
	
	if [ "$EncryptionOrRange" == "RangeAth9k" ]; then
                nice -n -5 /tmp/rctx $ChannelToListen2 $PrimaryCardMAC
        fi
	
    	sleep 1
    done
}
