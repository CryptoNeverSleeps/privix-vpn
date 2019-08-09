#!/bin/bash
# Copyright (c) 2019 Privix. Released under the MIT License.

RED='\033[0;31m'
GREEN='\033[0;32m'
# Ask user if they would like to install the vpn software after node install.
	echo "${GREEN}Please read the terms of service document that can be located here: Privix.io${GREEN}"
    echo "Would you like to install Privix VPN and accept the Terms? Y or N}> "
read USER_INPUT
if [ $USER_INPUT == "Y" ] ||
   [ $USER_INPUT == "y" ]; then
		cd
		cd Privix-vpn
		cd VPN
		cd privixvpn
		bash install.sh
	else  
		echo Vpx configuration file created successfully. 
		echo Vpx Server Started Successfully using the command ./privixd -daemon
		echo If you get a message asking to rebuild the database, please hit Ctr + C and run ./privixd -daemon -reindex
		echo If you still have further issues please reach out to support in our Discord channel. 
		echo Please use the following Private Key when setting up your wallet: $GENKEY
	exit 0
fi