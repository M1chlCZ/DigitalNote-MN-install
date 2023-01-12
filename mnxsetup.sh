#!/bin/bash    


# Check for systemd
systemctl --version >/dev/null 2>&1 || { echo "Ubuntu 18.04+ is required. Are you using Ubuntu 16.04?"  >&2; exit 1; }

clear 


echo "This is utility for setting up second MN on VPS with additional IPv6, refer to your VPS provider for info how to set it up."
echo "!IMPORTANT! Please make sure that your daemon is fully synced! Otherwise you are going to have sync each MN"
read -p "Press enter to continue, or ctrl+c to terminate this procedure " -n1 -s
clear

echo "Checking IPv6, please wait"

if [ -z "$NUMBER" ]; then
    read -p "Please enter how much masternodes you want to setup: " NUMBER
fi

if [ -z "$ARGUMENTNUMBER" ]; then
        if [ -z "$NUMBER" ]; then
            echo "You must specified number of MNs!"
            exit 1
        else
            re='^[0-9]+$'
            if ! [[ $NUMBER =~ $re ]] ; then
                echo "error: Not a number" >&2
                exit 1
            fi
            clear
            echo "Script will setup ${NUMBER} Mastenodes"
            sleep 2
        fi
            
fi

NETPLAN=false
for file in /etc/netplan/*.yaml
do
  if [ -e "$file" ]
  then
    NETPLAN=true
    break
    else
    NETPLAN=false
    break
  fi
done

if [ "$NETPLAN" = false ]; then
    echo "Netplan is required"  >&2; exit 1;
fi

if [ -z "$EXTERNALIP" ]; then
    EXTERNALIP=$(dig +short -6 myip.opendns.com aaaa @resolver1.ipv6-sandbox.opendns.com)
fi

if [ -z "$ARGUMENTIP" ]; then
      if [ -z "$EXTERNALIP" ]; then
            echo "Script tried unsuccessfully find your IPv6 interface, please make sure you have IPv6 activated on this VPS"
            echo ""
            sleep 2
            exit 1
       else
            echo "Please confirm your IP address by pressing ENTER"
            echo ""
      fi
    read -e -p "Server IPv6 Address: " -i $EXTERNALIP -e IP
fi

IFS=':' read -r -a array <<< "$EXTERNALIP"
CUTIP=""

arraylength=${#array[@]}
for ((i=1; i<arraylength+1; i++));
do

if [ $i -ne "$arraylength" ]; then
        CUTIP+="${array[$i-1]}:"
else
        CUTIP+=""
fi
done


NETMASK=$(ifconfig | grep "$EXTERNALIP" | grep -oP '(?<=prefixlen )[^ ]*')
NETMASK4=$(ifconfig | grep -oP '(?<=netmask )[^ ]*' | head -n1)
IP4=$(ifconfig | grep -oP '(?<=inet )[^ ]*' | head -n1)
GATEWAY=$(/bin/ip route | grep -oP '(?<=via )[^ ]*' | head -n 1)
#LASTNUM=$(echo "$EXTERNALIP" | cut -d':' -f 8)
#CUTIP=$(echo "$EXTERNALIP" | rev | cut -c5- | rev)
INTERFACE=$(/bin/ip link show | grep -oP '(?<=2: )[^ ]*' | cut -d':' -f 1)


if [ "$NETMASK4" == "255.255.255.255" ]; then
    BITS4="32"
elif [ "$NETMASK4" == "255.255.255.254" ]; then
    BITS4="31"
elif [ "$NETMASK4" == "255.255.255.252" ]; then
    BITS4="29"
elif [ "$NETMASK4" == "255.255.255.248" ]; then
    BITS4="28"
elif [ "$NETMASK4" == "255.255.255.224" ]; then
    BITS4="27"
elif [ "$NETMASK4" == "255.255.255.192" ]; then
    BITS4="26"
elif [ "$NETMASK4" == "255.255.255.128" ]; then
    BITS4="25"
elif [ "$NETMASK4" == "255.255.255.0" ]; then
    BITS4="24"
elif [ "$NETMASK4" == "255.255.254.0" ]; then
    BITS4="23"
elif [ "$NETMASK4" == "255.255.252.0" ]; then
    BITS4="22"
elif [ "$NETMASK4" == "255.255.248.0" ]; then
    BITS4="21"
elif [ "$NETMASK4" == "255.255.240.0" ]; then
    BITS4="20"
elif [ "$NETMASK4" == "255.255.224.0" ]; then
    BITS4="19"
elif [ "$NETMASK4" == "255.255.192.0" ]; then
    BITS4="18"
fi

NEWIP=""

for ((i=1; i<$NUMBER+1; i++)); 
do
    if [ $i -lt 10 ]; then
        PREFIX="000"
    elif [ $i -lt 100 ]; then
        PREFIX="00" 
    elif [ $i -lt 1000 ]; then
        PREFIX="0"
    fi
    NEWIP+=",'$CUTIP$PREFIX$i/$NETMASK'"

done

pkgs='netplan.io rsync'
install=false
for pkg in $pkgs; do
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
    install=true
  fi
  if "$install"; then
    apt-get install -y $pkg
    install=false
  fi
done

mkdir ~/netplan-bc

cd /etc/netplan || exit
cp * ~/netplan-bc/
rm *

touch 50-cloud-init.yaml

cat > 50-cloud-init.yaml << EOL
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      dhcp4: no
      addresses: [$IP4/$BITS4,'$EXTERNALIP/$NETMASK'$NEWIP]
      gateway4: $GATEWAY
      nameservers:
        addresses: [8.8.8.8]
      routes:
      - to: 169.254.0.0/16
        via: $GATEWAY
        metric: 100
EOL

netplan apply

cd


systemctl stop xdn.service
sleep 2

rm ~/.XDN/debug.log
touch ~/.XDN/debug.log

for ((i=1; i<$NUMBER+1; i++));
do
    NUM=$(($i + 1))
    echo "Copying blockchain for Mastenode $i"
    rsync -av --progress ~/.XDN/* ~/.XDN$NUM
    rm ~/.XDN$NUM/wallet.dat
    rm ~/.XDN$NUM/DigitalNote.conf
    clear
done


systemctl start xdn.service

clear

echo "setting up configs"

for ((i=1; i<$NUMBER+1; i++));
do
    NUM=$(($i + 1))
    if [ $i -lt 10 ]; then
        PR="000"
    elif [ $i -lt 100 ]; then
        PR="00"
    elif [ $i -lt 1000 ]; then
        PR="0"
    fi
    read -p "Please enter Masternode #$i key: " MNK

    echo ""
    echo "Add this to your masternode.conf on your local machine: <MN name> [${EXTERNALIP}]:19427 ${MNK} <TX ID>"
    echo ""

    USER=root
    RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
    RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

touch ~/.XDN$NUM/DigitalNote.conf
cat > ~/.XDN$NUM/DigitalNote.conf << EOL
${INSTALLERUSED}
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcallowip=127.0.0.1
rpcport=12$PR$i
listen=1
server=1
daemon=1
maxconnections=150
externalip=[$CUTIP$i]
bind=[$CUTIP$i]:19427
masternodeaddr=[$CUTIP$i]:19427
masternodeprivkey=$MNK
masternode=1
addnode=157.230.107.144:19427
addnode=89.40.10.129:19427
addnode=45.77.58.250:19427
addnode=104.131.27.134:19427
EOL

chmod 0600 ~/.XDN$NUM/DigitalNote.conf
chown -R $USER:$USER ~/.XDN$NUM

cat > /etc/systemd/system/xdn$NUM.service << EOL
[Unit]
Description=CCASHD$NUM
After=network.target
[Service]
Type=forking
User=root
WorkingDirectory=/root/
ExecStart=/root/Campusd -conf=/root/.XDN$NUM/DigitalNote.conf -datadir=/root/.XDN$NUM -listen=12$PR$i
ExecStop=/root/Campusd -conf=/root/.XDN$NUM/DigitalNote.conf -datadir=/root/.XDN$NUM -listen=12$PR$i stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL


    sudo systemctl enable xdn$NUM.service
    sudo systemctl start xdn$NUM.service
done

echo "" && echo "$Number Masternodes are completed" && echo ""

cat << "EOF"
           |Brought to you by|         
  __  __ _  ____ _   _ _     ____ _____
 |  \/  / |/ ___| | | | |   / ___|__  /
 | |\/| | | |   | |_| | |  | |     / / 
 | |  | | | |___|  _  | |__| |___ / /_ 
 |_|  |_|_|\____|_| |_|_____\____/____|
       For complains Tweet @M1chl 

XDN: dUUhW8oUsuB7GieV1PkqEctArPLvS5j7a2

EOF

rm ~/mnxsetup.sh
read -p "Press Enter to continue" -n1 -s