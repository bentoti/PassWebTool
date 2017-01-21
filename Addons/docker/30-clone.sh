#!/bin/bash
echo ">>>>>>>>> $0: installing git <<<<<<<<<"
yum install -y git  libgnome-keyring perl-Error perl-TermReadKey rsync

echo ">>>>>>>>> $0: cloning PassWebTool <<<<<<<<<"
cd /opt
git clone https://github.com/maldex/PassWebTool.git
cd PassWebTool
rm -rf Addons/
git pull || exit 255
mkdir var/log

echo ">>>>>>>>> $0: removing git <<<<<<<<<"
yum remove -y git  libgnome-keyring perl-Error perl-TermReadKey rsync

echo ">>>>>>>>> $0: generating htpasswd <<<<<<<<<"
htpasswd -b -c etc/pwt.htpasswd pwt password

