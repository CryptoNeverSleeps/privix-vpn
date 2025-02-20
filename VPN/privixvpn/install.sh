#!/usr/bin/env bash
# Copyright (c) 2019 Privix. Released under the MIT License.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logs API Call.
LOG_FILE="/etc/openvpn/mn_check_log.txt"
LOGTIME=`date "+%Y-%m-%d %H:%M:%S"`
EXTIP="$(ip route get 1 | awk '{print $NF;exit}')"


STARTDIR=$(pwd)

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/env.sh

if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

echo
echo "Creating backup..."
$DIR/backup.sh

echo
echo "Installing OpenVPN..."
eval $PCKTMANAGER update
if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	eval $INSTALLER epel-release
fi
eval $INSTALLER openvpn easy-rsa $CRON_PACKAGE $IPTABLES_PACKAGE procps net-tools

echo
echo "Configuring routing..."
$DIR/sysctl.sh

echo
echo "Installing configuration files..."
yes | cp -rf $DIR/openvpn-server.conf.dist $OPENVPNCONFIG

sed -i -e "s@OPENVPNDIR@$OPENVPNDIR@g" $OPENVPNCONFIG
sed -i -e "s@CADIR@$CADIR@g" $OPENVPNCONFIG
sed -i -e "s@LOCALPREFIX@$LOCALPREFIX@g" $OPENVPNCONFIG
sed -i -e "s@NOBODYGROUP@$NOBODYGROUP@g" $OPENVPNCONFIG

echo
echo "Configuring iptables firewall..."
$DIR/iptables-setup.sh

echo
echo "Configuring DNS parameters..."
$DIR/dns.sh

echo
echo "Creating server keys..."
if [ "$PLATFORM" == "$CENTOSPLATFORM" ]; then
	mkdir -p "$CADIR/keys"
	cp -rf /usr/share/easy-rsa/2.0/* $CADIR
fi
if [ "$PLATFORM" == "$DEBIANPLATFORM" ]; then
	make-cadir $CADIR
fi

# workaround: Debian's openssl version is not compatible with easy-rsa
# using openssl-1.0.0.cnf if openssl.cnf not exists
cp -n /etc/openvpn/easy-rsa/openssl-1.0.0.cnf /etc/openvpn/easy-rsa/openssl.cnf

cd $CADIR
source ./vars
./clean-all
./build-ca
./build-key-server --batch openvpn-server
./build-dh
openvpn --genkey --secret ta.key

# add dummy user and revoke its certificate for non-empty crl.pem file
./build-key --batch client000
$DIR/deluser.sh client000

echo
echo "Adding cron jobs..."
yes | cp -rf $DIR/checkserver.sh $CHECKSERVER
$DIR/autostart.sh

cd $STARTDIR
echo
echo "Configuring VPN users..."
$DIR/adduser.sh

echo
echo "Starting OpenVPN..."
systemctl -f enable openvpn@openvpn-server
systemctl restart openvpn@openvpn-server

## Create the cronjob
echo -e ${LOGTIME} " : User ${GREEN}${USER}${NC} on vps ${BLUE}${EXTIP}${NC} has just finished setting up the privixvpn and is moving to run Masternode Verification Checks." >> ${LOG_FILE}
cd
cd privix-vpn/VPN/Check
bash MN_Check.sh

echo
echo "Installation script has been completed!"