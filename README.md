# DigitalNote Masternode install script

Script to install a DigitalNote Masternode on Linux VPS

1) Make sure that you have your Masternode setup up locally
2) You can use any VPS with minimum of 512MB RAM with Ubuntu 18.04+ OS and Netplan Network Manager

Paste this into terminal:

```
wget https://raw.githubusercontent.com/M1chlCZ/DigitalNote-MN-install/main/xdnMNinstall.sh && sudo bash xdnMNinstall.sh && . ~/.profile
```
And follow on screen prompts.

This script contains additional commands, which can be used anywhere. Here is list of them.
```
Command              | What does it do?
---------------------------------------------------
getinfo              | Get wallet info

mnstart              | Start masternode

mnstatus             | Status of the masternode

mnxstatus N          | Status of the masternode #N

startd               | Start DigitalNote deamon

startd2              | Start DigitalNote deamon for MN #2

startdx N            | Start DigitalNote deamon #<N>

stopd                | Stop DigitalNote deamon

stopd2               | Stop DigitalNote deamon for MN #2

stopdx N             | Stop DigitalNote deamon #N

mn2start             | Start MN #2

mn2status            | Status of MN #2

mnxstatus N          | Status of MN #2

campusUpdate         | Update DigitalNote deamon

commandUpdate        | Update List of commands

xdnBetaInstall       | Installs a beta version of daemon

getBootstrap         | Get a bootstrap

getBootstrap2        | Get a bootstrap for MN #2

getBootstrapx N      | Get a bootstrap for MN #N

getPeers             | Get peers for daemon

getxPeers N          | Get peers for daemon #N

getpeerinfo          | Show peer info

clearbanned          | Clear all banned IPs

getinfo2             | Get 2nd deamon info

mn2setup             | Set up MN #2

mnxsetup N           | Set up MN #N

gethelp              | Show help
---------------------------------------------------
```

Any help with this script can be provided through:


Twitter: https://ctt.ac/38x8c 

