#!/bin/bash
# Copyright (c) 2019 Privix. Released under the MIT License.

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=6
BACKTITLE="Terms Check"
TITLE="VPX VPN Terms And Condidtions"
MENU="Do You Accept The Terms and conditions here: privix.io"

OPTIONS=(1 "Yes Proceed to read Terms of Service"
		 2 "Yes Proceed without reading"
		 3 "No"
)


CHOICE=$(whiptail --clear\
		--backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1) # Yes read the terms of service docoument
		cd
		cd privix-vpn/Docs
		head -20 <Terms.md>
        ;;

		2) # Yes move to vpn selection
		cd
		cd privix-vpn/VPN/
		bash VPN_Selection_Install.sh
        ;;
	    
        3) # No Exit
		exit 1
		;;


esac