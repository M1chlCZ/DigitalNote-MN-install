#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -a | --advanced)
        ADVANCED="y"
        shift
        ;;
    -n | --normal)
        ADVANCED="n"
        FAIL2BAN="y"
        UFW="y"
        BOOTSTRAP="y"
        shift
        ;;
    -i | --externalip)
        EXTERNALIP="$2"
        ARGUMENTIP="y"
        shift
        shift
        ;;
    -k | --privatekey)
        KEY="$2"
        shift
        shift
        ;;
    -f | --fail2ban)
        FAIL2BAN="y"
        shift
        ;;
    --no-fail2ban)
        FAIL2BAN="n"
        shift
        ;;
    -u | --ufw)
        UFW="y"
        shift
        ;;
    --no-ufw)
        UFW="n"
        shift
        ;;
    -b | --bootstrap)
        BOOTSTRAP="y"
        shift
        ;;
    --no-bootstrap)
        BOOTSTRAP="n"
        shift
        ;;
    -s | --swap)
        SWAP="y"
        shift
        ;;
    --no-swap)
        SWAP="n"
        shift
        ;;
    -h | --help)
        cat <<EOL
CCASH Masternode installer arguments:
    -n --normal               : Run installer in normal mode
    -a --advanced             : Run installer in advanced mode
    -i --externalip <address> : Public IP address of VPS
    -k --privatekey <key>     : Private key to use
    -f --fail2ban             : Install Fail2Ban
    --no-fail2ban             : Don't install Fail2Ban
    -u --ufw                  : Install UFW
    --no-ufw                  : Don't install UFW
    -b --bootstrap            : Sync node using Bootstrap
    --no-bootstrap            : Don't use Bootstrap
    -h --help                 : Display this help text.
    -s --swap                 : Create swap for <2GB RAM
EOL
        exit
        ;;
    *)                     # unknown option
        POSITIONAL+=("$1") # save it in an array for later
        shift
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

clear

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

# Install tools for dig and systemctl
echo "Preparing installation..."
apt-get install git dnsutils systemd -y >/dev/null 2>&1
killall DigitalNoted >/dev/null 2>&1

# Check for systemd
systemctl --version >/dev/null 2>&1 || {
    echo "systemd is required. Are you using Ubuntu 16.04?" >&2
    exit 1
}

# Getting external IP
if [ -z "$EXTERNALIP" ]; then
    EXTERNALIP=$(dig +short myip.opendns.com @resolver1.opendns.com)
fi
clear

if [ -z "$ADVANCED" ]; then

cat <<"EOF"
$$\   $$\ $$$$$$$\  $$\   $$\       $$\      $$\ $$\   $$\       $$$$$$\ $$\   $$\  $$$$$$\ $$$$$$$$\  $$$$$$\  $$\       $$\       
$$ |  $$ |$$  __$$\ $$$\  $$ |      $$$\    $$$ |$$$\  $$ |      \_$$  _|$$$\  $$ |$$  __$$\\__$$  __|$$  __$$\ $$ |      $$ |      
\$$\ $$  |$$ |  $$ |$$$$\ $$ |      $$$$\  $$$$ |$$$$\ $$ |        $$ |  $$$$\ $$ |$$ /  \__|  $$ |   $$ /  $$ |$$ |      $$ |      
 \$$$$  / $$ |  $$ |$$ $$\$$ |      $$\$$\$$ $$ |$$ $$\$$ |        $$ |  $$ $$\$$ |\$$$$$$\    $$ |   $$$$$$$$ |$$ |      $$ |      
 $$  $$<  $$ |  $$ |$$ \$$$$ |      $$ \$$$  $$ |$$ \$$$$ |        $$ |  $$ \$$$$ | \____$$\   $$ |   $$  __$$ |$$ |      $$ |      
$$  /\$$\ $$ |  $$ |$$ |\$$$ |      $$ |\$  /$$ |$$ |\$$$ |        $$ |  $$ |\$$$ |$$\   $$ |  $$ |   $$ |  $$ |$$ |      $$ |      
$$ /  $$ |$$$$$$$  |$$ | \$$ |      $$ | \_/ $$ |$$ | \$$ |      $$$$$$\ $$ | \$$ |\$$$$$$  |  $$ |   $$ |  $$ |$$$$$$$$\ $$$$$$$$\ 
\__|  \__|\_______/ \__|  \__|      \__|     \__|\__|  \__|      \______|\__|  \__| \______/   \__|   \__|  \__|\________|\________|
                                                                                                    
EOF

    echo "

     +---------MASTERNODE INSTALLER v1 ---------+
 |                                                  |
 | You can choose between two installation options: |::
 |              default and advanced.               |::
 |                                                  |::
 |  The advanced installation will install and run  |::
 |   the masternode under a non-root user. If you   |::
 |   don't know what that means, use the default    |::
 |               installation method.               |::
 |                                                  |::
 |  Otherwise, your masternode will not work, and   |::
 |    the DigitalNote Team WILL NOT assist you in    |::
 |                 repairing it.                    |::
 |                                                  |::
 |           You will have to start over.           |::
 |                                                  |::
 +--------------------------------------------------+
 ::::::::::::::::::::::::::::::::::::::::::::::::::::

"

    sleep 5
fi

if [ -z "$ADVANCED" ]; then
    read -e -p "Use the Advanced Installation? [N/y] : " ADVANCED
fi

if [[ ("$ADVANCED" == "y" || "$ADVANCED" == "Y") ]]; then
    USER=$USER
    INSTALLERUSED="#Used Advanced Install"

    echo "" && echo 'Using advance install' && echo ""
    sleep 1
else
    USER=$USER
    UFW="y"
    INSTALLERUSED="#Used Basic Install"
    BOOTSTRAP="y"
fi


if [ -z "$KEY" ]; then
    read -e -p "Masternode Private Key : " KEY
fi

if [ -z "$SWAP" ]; then
    read -e -p "Does VPS use less than 2GB RAM? [Y/n] : " SWAP
fi

if [ -z "$UFW" ]; then
    read -e -p "Install UFW and configure ports? [Y/n] : " UFW
fi

if [ -z "$ARGUMENTIP" ]; then
    read -e -p "Server IP Address: " -i $EXTERNALIP -e IP
fi

if [ -z "$BOOTSTRAP"]; then
    read -e -p "Download bootstrap for fast sync? [Y/n] : " BOOTSTRAP
fi

clear

# Generate random passwords
RPCUSER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
RPCPASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo "Configuring swap file..."
# Configuring SWAPT
if [[ ("$SWAP" == "y" || "$SWAP" == "Y" || "$SWAP" == "") ]]; then
    cd $HOME
    sudo swapoff -a
    sudo dd if=/dev/zero of=/swapfile bs=6144 count=1048576
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
fi
clear

# update packages and upgrade Ubuntu
echo "Installing dependencies..."
YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)
PACMAN_CMD=$(which pacman)

if [[ ! -z $YUM_CMD ]]; then
    echo "using YUM"
    yum check-update
elif [[ ! -z $APT_GET_CMD ]]; then
    apt-get update
elif [[ ! -z $PACMAN_CMD ]]; then
    yes | LC_ALL=en_US.UTF-8 pacman -S $pkg
else
    echo "Cannot update repository"
    exit 1;
fi



pkgs='build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev libcurl4-openssl-dev curl libzip-dev ntp git make automake build-essential libboost-all-dev yasm binutils libcurl4-openssl-dev openssl libssl-dev libgmp-dev libtool qt5-default qttools5-dev-tools'
install=false
for pkg in $pkgs; do
  status="$(dpkg-query -W --showformat='${db:Status-Status}' "$pkg" 2>&1)"
  if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
    install=true
  fi
  if "$install"; then
    if [[ ! -z $YUM_CMD ]]; then
        yum -y install $pkg
    elif [[ ! -z $APT_GET_CMD ]]; then
        DEBIAN_FRONTEND=noninteractive apt-get -qq -y install $pkg
    elif [[ ! -z $PACMAN_CMD ]]; then
        yes | LC_ALL=en_US.UTF-8 pacman -S $pkg
    else
        echo "error can't install package $pkg"
        exit 1;
    fi    
    install=false
  fi
done
clear

echo "Configuring UFW..."
# Install UFW
if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
    apt-get -qq install ufw
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    ufw allow 19427/tcp
    yes | ufw enable
fi
clear

# Install Berkley DB 6.2
echo "Installing Berkley DB..."
cd $HOME
wget http://download.oracle.com/berkeley-db/db-6.2.32.NC.tar.gz
tar zxf db-6.2.32.NC.tar.gz
cd db-6.2.32.NC/build_unix
../dist/configure --enable-cxx --disable-shared
make
make install
ln -s /usr/local/BerkeleyDB.6.2/lib/libdb-6.2.so /usr/lib/libdb-6.2.so
ln -s /usr/local/BerkeleyDB.6.2/lib/libdb_cxx-6.2.so /usr/lib/libdb_cxx-6.2.so
export BDB_INCLUDE_PATH="/usr/local/BerkeleyDB.6.2/include"
export BDB_LIB_PATH="/usr/local/BerkeleyDB.6.2/lib"
cd $HOME
rm db-6.2.32.NC.tar.gz
rm -rf --interactive=never db-6.2.32.NC

# Install XDN daemon
cd $HOME
git clone https://github.com/DigitalNoteXDN/DigitalNote-2.git DigitalNote
cd $HOME/DigitalNote/src
chmod a+x obj
chmod a+x leveldb/build_detect_platform
chmod a+x secp256k1
chmod a+x leveldb
chmod a+x $HOME/DigitalNote/src
chmod a+x $HOME/DigitalNote
make -f makefile.unix USE_UPNP=- -j`nproc`
sleep 1
cp DigitalNoted $HOME/DigitalNoted
cd $HOME
strip DigitalNoted
sleep 1

clear

# Create XDN directory
mkdir $HOME/.XDN

# Bootstrap
if [[ ("$BOOTSTRAP" == "y" || "$BOOTSTRAP" == "Y" || "$BOOTSTRAP" == "") ]]; then
    echo "Downloading bootstrap..."
    cd $HOME/.XDN
    wget https://dex.digitalnote.org/api/blockchain.zip
    unzip blockchain.zip
    rm blockchain.zip
    cd $HOME
fi

# Create DigitalNote.conf
touch $HOME/.XDN/DigitalNote.conf
cat >$HOME/.XDN/DigitalNote.conf <<EOL
${INSTALLERUSED}
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
logips=1
externalip=${IP}
bind=${IP}:18092
masternodeaddr=${IP}:18092
masternodeprivkey=${KEY}
masternode=1
addnode=103.164.54.203
addnode=192.241.147.56
addnode=20.193.89.74
addnode=161.97.92.102
addnode=161.97.106.85:18060
addnode=161.97.106.85:18061
addnode=161.97.106.85:18062
addnode=161.97.106.85:18063
addnode=95.111.225.123:18063
addnode=95.111.225.123:18092
addnode=62.171.150.246:18060
addnode=62.171.150.246:18062
addnode=62.171.150.246:18064
addnode=62.171.150.246:18066
addnode=62.171.150.246:18068
addnode=62.171.150.246:18070
addnode=62.171.150.246:18072
addnode=62.171.150.246:18093
addnode=seed1n.digitalnote.biz
addnode=seed2n.digitalnote.biz
addnode=seed3n.digitalnote.biz
addnode=seed4n.digitalnote.biz
EOL
chmod 0600 $HOME/.XDN/DigitalNote.conf
chown -R $USER:$USER $HOME/.XDN

sleep 1
clear

#Set up enviroment variables
cd $HOME

wget https://raw.githubusercontent.com/M1chlCZ/DigitalNote-MN-install/main/env.sh
source env.sh
source $HOME/.profile

clear

echo "Setting up XDN daemon..."
cat >/etc/systemd/system/xdn.service <<EOL
[Unit]
Description=XDND
After=network.target
[Service]
Type=forking
User=${USER}
WorkingDirectory=$HOME/
ExecStart=$HOME/DigitalNoted -conf=$HOME/.XDN/DigitalNote.conf -datadir=$HOME/.XDN
ExecStop=$HOME/DigitalNoted -conf=$HOME/.XDN/DigitalNote.conf -datadir=$HOME/.XDN stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL
sudo systemctl daemon-reload
sudo systemctl enable xdn.service
sudo systemctl start xdn.service

clear

cat <<EOL
Now, you need to wait for sync you can check the progress by typing getinfo. After full sync please go to your desktop wallet
Click the Masternodes tab
Click Start all at the bottom

If for some reason commands such as mnstart, mnstatus, getinfo did not work, please log out of this session and log back in.

EOL

read -p "Press Enter to continue after read to continue. " -n1 -s
clear

#File cleanup
rm -r $HOME/DigitalNote
rm -rf $HOME/xdnMNinstall.sh

echo "" && echo "Masternode setup complete" && echo ""

cat <<"EOF"
           |Brought to you by|         
  __  __ _  ____ _   _ _     ____ _____
 |  \/  / |/ ___| | | | |   / ___|__  /
 | |\/| | | |   | |_| | |  | |     / / 
 | |  | | | |___|  _  | |__| |___ / /_ 
 |_|  |_|_|\____|_| |_|_____\____/____|
       For complains Tweet @M1chl 

XDN: dUUhW8oUsuB7GieV1PkqEctArPLvS5j7a2

EOF
