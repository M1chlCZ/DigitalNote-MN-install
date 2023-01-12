#!/bin/bash
echo "Setting up enviromental commands..."
cd $HOME
mkdir -p .commands
mkdir -p .profile
echo "export PATH="$PATH:$HOME/.commands"" >>$HOME/.profile


rm  $HOME/.commands/gethelp > /dev/null 2>&1
rm  $HOME/.commands/getinfo > /dev/null 2>&1
rm  $HOME/.commands/mnstart > /dev/null 2>&1
rm  $HOME/.commands/mnstatus > /dev/null 2>&1
rm  $HOME/.commands/mnxstatus > /dev/null 2>&1
rm  $HOME/.commands/startd > /dev/null 2>&1
rm  $HOME/.commands/stopd > /dev/null 2>&1
rm  $HOME/.commands/commandUpdate > /dev/null 2>&1
rm  $HOME/.commands/xdnUpdate > /dev/null 2>&1
rm  $HOME/.commands/clearbanned > /dev/null 2>&1
rm  $HOME/.commands/getBootstrap > /dev/null 2>&1
rm  $HOME/.commands/getBootstrap2 > /dev/null 2>&1
rm  $HOME/.commands/mn2setup > /dev/null 2>&1
rm  $HOME/.commands/mnxsetup > /dev/null 2>&1
rm  $HOME/.commands/mn2start > /dev/null 2>&1
rm  $HOME/.commands/mn2status > /dev/null 2>&1
rm  $HOME/.commands/startd2 > /dev/null 2>&1
rm  $HOME/.commands/stopd2 > /dev/null 2>&1
rm  $HOME/.commands/startdx > /dev/null 2>&1
rm  $HOME/.commands/stopdx > /dev/null 2>&1
rm  $HOME/.commands/xdnBetaInstall > /dev/null 2>&1
rm  $HOME/.commands/getBootstrapx > /dev/null 2>&1
rm  $HOME/.commands/getxinfo > /dev/null 2>&1
rm  $HOME/.commands/mnxstatus > /dev/null 2>&1
rm  $HOME/.commands/getPeers > /dev/null 2>&1
rm  $HOME/.commands/getxPeers > /dev/null 2>&1
rm  $HOME/.commands/xdnVersionInstall > /dev/null 2>&1
rm  $HOME/.commands/addnode > /dev/null 2>&1
rm  $HOME/.commands/addnodex > /dev/null 2>&1
rm  $HOME/.commands/addnode2 > /dev/null 2>&1

cat > $HOME/.commands/gethelp << EOL
#!/bin/bash

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
echo ""
echo "Here is list of commands for you DigitalNote service"
echo "you can type these commands anywhere in terminal."
echo ""
echo "Command              | What does it do?"
echo "---------------------------------------------------"
echo "getinfo              | Get wallet info"
echo ""
echo "mnstart              | Start masternode"
echo ""
echo "mnstatus             | Status of the masternode"
echo ""
echo "mnxstatus N          | Status of the masternode #N"
echo ""
echo "startd               | Start DigitalNote deamon"
echo ""
echo "startd2              | Start DigitalNote deamon for MN #2"
echo ""
echo "startdx N            | Start DigitalNote deamon #<N>"
echo ""
echo "stopd                | Stop DigitalNote deamon"
echo ""
echo "stopd2               | Stop DigitalNote deamon for MN #2"
echo ""
echo "stopdx N             | Stop DigitalNote deamon #N"
echo ""
echo "mn2start             | Start MN #2"
echo ""
echo "mn2status            | Status of MN #2"
echo ""
echo "mnxstatus N          | Status of MN #2"
echo ""
echo "xdnUpdate            | Update DigitalNote deamon"
echo ""
echo "commandUpdate        | Update List of commands"
echo ""
echo "xdnBetaInstall       | Installs a beta version of daemon"
echo ""
echo "getBootstrap         | Get a bootstrap"
echo ""
echo "getBootstrap2        | Get a bootstrap for MN #2"
echo ""
echo "getBootstrapx N      | Get a bootstrap for MN #N"
echo ""
echo "getpeerinfo          | Show peer info"
echo ""
echo "clearbanned          | Clear all banned IPs"
echo ""
echo "getinfo2             | Get 2nd deamon info"
echo ""
echo "mn2setup             | Set up MN #2"
echo ""
echo "mnxsetup N           | Set up MN #N"
echo ""
echo "gethelp              | Show help"
echo "---------------------------------------------------"
echo ""
EOL

cat > $HOME/.commands/getinfo << EOL
#!/bin/bash    
$HOME/DigitalNoted getinfo
EOL

cat > $HOME/.commands/getpeerinfo << EOL
#!/bin/bash    
$HOME/DigitalNoted getpeerinfo
EOL

cat > $HOME/.commands/mnstart << EOL
#!/bin/bash    
$HOME/DigitalNoted masternode start
EOL

cat > $HOME/.commands/mnstatus << EOL
#!/bin/bash    
$HOME/DigitalNoted masternode status
EOL

cat > $HOME/.commands/startd << EOL
#!/bin/bash
systemctl start xdn.service > /dev/null 2>&1
echo "DigitalNote Deamon is running..."
EOL

cat > $HOME/.commands/startdx << EOL
#!/bin/bash    
systemctl start xdn\$1.service 
echo "DigitalNote Deamon is running..."
EOL

cat > $HOME/.commands/stopdx << EOL
#!/bin/bash    
systemctl stop xdn\$1.service 
echo "DigitalNote Deamon is innactive..."
EOL


cat > $HOME/.commands/stopd << EOL
#!/bin/bash
systemctl stop xdn.service
sleep 1
echo "DigitalNote Deamon is innactive..."
EOL

cat > $HOME/.commands/clearbanned << EOL
#!/bin/bash    
$HOME/DigitalNoted clearbanned
EOL

cat > $HOME/.commands/getBootstrap << EOL
systemctl stop xdn.service

cd $HOME

mv  $HOME/.XDN/DigitalNote.conf DigitalNote.conf
mv  $HOME/.XDN/wallet.dat wallet.dat
mv  $HOME/.XDN/masternode.conf masternode.conf

pkgs='unzip'
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

cd $HOME/.XDN
rm -rf *
wget https://dex.digitalnote.org/api/blockchain.zip
unzip blockchain.zip
rm blockchain.zip
cd $HOME

mv DigitalNote.conf  $HOME/.XDN/DigitalNote.conf
mv wallet.dat  $HOME/.XDN/wallet.dat
mv masternode.conf $HOME/.XDN/masternode.conf 


systemctl start xdn.service> /dev/null 2>&1
echo "DigitalNote Deamon is running..."
EOL

cat > $HOME/.commands/getBootstrapx << EOL
systemctl stop ccash\$1.service 

cd $HOME

mv  $HOME/.XDN\$1/DigitalNote.conf DigitalNote.conf
mv  $HOME/.XDN\$1/wallet.dat wallet.dat
mv  $HOME/.XDN\$1/masternode.conf masternode.conf

pkgs='unzip'
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

cd $HOME/.XDN\$1
rm -rf *
wget https://dex.digitalnote.org/api/blockchain.zip
unzip blockchain.zip
rm blockchain.zip
cd $HOME

mv DigitalNote.conf  $HOME/.XDN\$1/DigitalNote.conf
mv wallet.dat  $HOME/.XDN\$1/wallet.dat
mv masternode.conf $HOME/.XDN\$1/masternode.conf

systemctl start ccash\$1.service > /dev/null 2>&1
echo "DigitalNote Deamon is running..."
EOL

cat > $HOME/.commands/commandUpdate << EOL
#!/bin/bash
cd $HOME 
wget https://raw.githubusercontent.com/M1chlCZ/DigitalNote-MN-install/main/env.sh > /dev/null 2>&1
source env.sh
clear

cat << "EOF"
            Update complete!

           |Brought to you by|         
  __  __ _  ____ _   _ _     ____ _____
 |  \/  / |/ ___| | | | |   / ___|__  /
 | |\/| | | |   | |_| | |  | |     / / 
 | |  | | | |___|  _  | |__| |___ / /_ 
 |_|  |_|_|\____|_| |_|_____\____/____|
       For complains Tweet @M1chl 

XDN: dUUhW8oUsuB7GieV1PkqEctArPLvS5j7a2

EOF

. $HOME/.commands/gethelp

echo ""
EOL

cat > $HOME/.commands/getBootstrap2 << EOL
systemctl stop xdn2.service 

cd $HOME

mv  $HOME/.XDN2/DigitalNote.conf DigitalNote.conf
mv  $HOME/.XDN2/wallet.dat wallet.dat
mv  $HOME/.XDN2/masternode.conf masternode.conf

pkgs='unzip'
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

cd $HOME/.XDN2
rm -rf *
wget https://dex.digitalnote.org/api/blockchain.zip
unzip blockchain.zip
rm blockchain.zip
cd $HOME

mv DigitalNote.conf  $HOME/.XDN2/DigitalNote.conf
mv wallet.dat  $HOME/.XDN2/wallet.dat
mv masternode.conf $HOME/.XDN2/masternode.conf
 
systemctl start xdn2.service > /dev/null 2>&1
echo "DigitalNote Deamon is running..."
EOL


cat > $HOME/.commands/xdnUpdate << EOL
#!/bin/bash    

cd $HOME

sudo systemctl stop xdn.service
sudo systemctl stop xdn*.service

rm -r DigitalNote > /dev/null 2>&1
killall DigitalNoted > /dev/null 2>&1
rm DigitalNoted > /dev/null 2>&1

export BDB_INCLUDE_PATH="/usr/local/BerkeleyDB.6.2/include"
export BDB_LIB_PATH="/usr/local/BerkeleyDB.6.2/lib"

cd $HOME
rm -r DigitalNote
git clone https://github.com/DigitalNoteXDN/DigitalNote-2.git DigitalNote
cd $HOME/DigitalNote/src
chmod a+x obj
chmod a+x leveldb/build_detect_platform
chmod a+x secp256k1
chmod a+x leveldb
chmod a+x $HOME/DigitalNote/src
chmod a+x $HOME/DigitalNote
make -f makefile.unix USE_UPNP=- -j$(nproc)
cd $HOME 
cp  DigitalNote/src/DigitalNoted  $HOME/DigitalNoted
cd $HOME

strip DigitalNoted

sleep 1

getBootstrap
getPeers

sudo systemctl start xdn.service
sudo systemctl start xdn*.service > /dev/null 2>&1

wget https://raw.githubusercontent.com/M1chlCZ/DigitalNote-MN-install/main/env.sh
source env.sh

sleep 5
source $HOME/.profile

rm -r DigitalNote

cat << "EOF"
            Update complete!

           |Brought to you by|         
  __  __ _  ____ _   _ _     ____ _____
 |  \/  / |/ ___| | | | |   / ___|__  /
 | |\/| | | |   | |_| | |  | |     / / 
 | |  | | | |___|  _  | |__| |___ / /_ 
 |_|  |_|_|\____|_| |_|_____\____/____|
       For complains Tweet @M1chl 

XDN: dUUhW8oUsuB7GieV1PkqEctArPLvS5j7a2

EOF

read -p "You may need run mnstart command to start a masternode after update. Press ENTER to continue " -n1 -s

echo ""
EOL

cat > $HOME/.commands/addnode << EOL
$HOME/DigitalNoted getpeerinfo | grep  -Po '"addr" : *\K"[^"]*"' | while read -r line; do
        temp="\${line%\"}"
        temp="\${temp#\"}"
        echo "addnode=\$temp"
done
EOL

cat > $HOME/.commands/addnode2 << EOL
#!/bin/bash    
PORT=\$((\$1 - 1))
$HOME/DigitalNoted -conf=$HOME/.XDN\$1/DigitalNote.conf -datadir=$HOME/.XDN\$1 -port=1200\$PORT getpeerinfo | grep  -Po '"addr" : *\K"[^"]*"' | while read -r line; do
        temp="\${line%\"}"
        temp="\${temp#\"}"
        echo "addnode=\$temp"
done
EOL

cat > $HOME/.commands/addnodex << EOL
#!/bin/bash    
$HOME/DigitalNoted -conf=$HOME/.XDN2/DigitalNote.conf -datadir=$HOME/.XDN2 getpeerinfo | grep  -Po '"addr" : *\K"[^"]*"' | while read -r line; do
        temp="\${line%\"}"
        temp="\${temp#\"}"
        echo "addnode=\$temp"
done
EOL

cat > $HOME/.commands/xdnBetaInstall << EOL
#!/bin/bash    
# Check if we are root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root! Aborting..." 1>&2
   exit 1
fi

cd $HOME

sudo systemctl stop xdn.service
sudo systemctl stop xdn2.service > /dev/null 2>&1

rm -r DigitalNote > /dev/null 2>&1
killall DigitalNoted > /dev/null 2>&1
rm DigitalNoted > /dev/null 2>&1

export BDB_INCLUDE_PATH="/usr/local/BerkeleyDB.6.2/include"
export BDB_LIB_PATH="/usr/local/BerkeleyDB.6.2/lib"

cd $HOME
git clone https://github.com/DigitalNoteXDN/DigitalNote-2.git DigitalNote
cd $HOME/DigitalNote/src
chmod a+x obj
chmod a+x leveldb/build_detect_platform
chmod a+x secp256k1
chmod a+x leveldb
chmod a+x $HOME/DigitalNote/src
chmod a+x $HOME/DigitalNote
make -f makefile.unix USE_UPNP=- -j$(nproc)
cd $HOME 
cp  DigitalNote/src/DigitalNoted $HOME/DigitalNoted


sleep 1

sudo systemctl start xdn.service
sudo systemctl start xdn2.service > /dev/null 2>&1

wget https://raw.githubusercontent.com/M1chlCZ/DigitalNote-MN-install/main/env.sh
source env.sh

sleep 5
source $HOME/.profile

rm -r DigitalNote

cat << "EOF"
            Update complete!

           |Brought to you by|         
  __  __ _  ____ _   _ _     ____ _____
 |  \/  / |/ ___| | | | |   / ___|__  /
 | |\/| | | |   | |_| | |  | |     / / 
 | |  | | | |___|  _  | |__| |___ / /_ 
 |_|  |_|_|\____|_| |_|_____\____/____|
       For complains Tweet @M1chl 

XDN: dUUhW8oUsuB7GieV1PkqEctArPLvS5j7a2

EOF

read -p "Beta version of DigitalNote is installed" -n1 -s

echo ""
EOL

cat > $HOME/.commands/mn2setup << EOL
cd $HOME
wget https://raw.githubusercontent.com/M1chlCZ/DigitalNote-MN-install/main/mn2.sh > /dev/null 2>&1
source mn2.sh
EOL

cat > $HOME/.commands/mnxsetup << EOL
cd $HOME
wget https://raw.githubusercontent.com/M1chlCZ/DigitalNote-MN-install/main/mnxsetup.sh > /dev/null 2>&1
chmod +x mnxsetup.sh
source mnxsetup.sh
EOL

cat > $HOME/.commands/getinfo2 << EOL
#!/bin/bash    
$HOME/DigitalNoted -conf=$HOME/.XDN2/DigitalNote.conf -datadir=$HOME/.XDN2 getinfo
EOL

cat > $HOME/.commands/mn2start << EOL
#!/bin/bash    
$HOME/DigitalNoted -conf=$HOME/.XDN2/DigitalNote.conf -datadir=$HOME/.XDN2 -port=12001 masternode start
EOL

cat > $HOME/.commands/mnxstart << EOL
#!/bin/bash    
PORT=\$((\$1 - 1))
$HOME/DigitalNoted -conf=$HOME/.XDN\$1/DigitalNote.conf -datadir=$HOME/.XDN\$1 -port=1200\$PORT masternode start
EOL

cat > $HOME/.commands/mnxstatus << EOL
#!/bin/bash    
PORT=\$((\$1 - 1))
$HOME/DigitalNoted -conf=$HOME/.XDN\$1/DigitalNote.conf -datadir=$HOME/.XDN\$1 -port=1200\$PORT masternode status
EOL

cat > $HOME/.commands/getxinfo << EOL
#!/bin/bash    
PORT=\$((\$1 - 1))
$HOME/DigitalNoted -conf=$HOME/.XDN\$1/DigitalNote.conf -datadir=$HOME/.XDN\$1 -port=1200\$PORT getinfo
EOL

cat > $HOME/.commands/mnxstatus << EOL
#!/bin/bash    
PORT=\$((\$1 - 1))
$HOME/DigitalNoted -conf=$HOME/.XDN\$1/DigitalNote.conf -datadir=$HOME/.XDN\$1 -port=1200\$PORT masternode status
EOL

cat > $HOME/.commands/mn2status << EOL
#!/bin/bash    
$HOME/DigitalNoted -conf=$HOME/.XDN2/DigitalNote.conf -datadir=$HOME/.XDN2 masternode status
EOL

cat > $HOME/.commands/startd2 << EOL
#!/bin/bash
systemctl start xdn2.service > /dev/null 2>&1
echo "DigitalNote Deamon #2 is running..."
EOL

cat > $HOME/.commands/stopd2 << EOL
#!/bin/bash
systemctl stop xdn2.service
sleep 1
echo "DigitalNote Deamon #2 is innactive..."
EOL


chmod +x  $HOME/.commands/getinfo
chmod +x  $HOME/.commands/mnstart
chmod +x  $HOME/.commands/mnstatus
chmod +x  $HOME/.commands/startd
chmod +x  $HOME/.commands/stopd
chmod +x  $HOME/.commands/commandUpdate
chmod +x  $HOME/.commands/xdnUpdate
chmod +x  $HOME/.commands/gethelp
chmod +x  $HOME/.commands/getpeerinfo
chmod +x  $HOME/.commands/clearbanned
chmod +x  $HOME/.commands/getBootstrap
chmod +x  $HOME/.commands/getBootstrap2
chmod +x  $HOME/.commands/getinfo2
chmod +x  $HOME/.commands/mn2setup
chmod +x  $HOME/.commands/mnxsetup
chmod +x  $HOME/.commands/mnxstart
chmod +x  $HOME/.commands/mn2start
chmod +x  $HOME/.commands/mn2status
chmod +x  $HOME/.commands/startd2
chmod +x  $HOME/.commands/stopd2
chmod +x  $HOME/.commands/startdx
chmod +x  $HOME/.commands/stopdx
chmod +x  $HOME/.commands/xdnBetaInstall
chmod +x  $HOME/.commands/getBootstrapx
chmod +x  $HOME/.commands/getxinfo
chmod +x  $HOME/.commands/mnxstatus
chmod +x  $HOME/.commands/getPeers
chmod +x  $HOME/.commands/getxPeers
chmod +x  $HOME/.commands/mnxstatus 
chmod +x  $HOME/.commands/xdnVersionInstall
chmod +x  $HOME/.commands/addnode
chmod +x  $HOME/.commands/addnodex
chmod +x  $HOME/.commands/addnode2

. .commands/gethelp

rm $HOME/env.sh > /dev/null 2>&1