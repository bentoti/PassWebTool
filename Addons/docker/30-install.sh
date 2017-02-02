#!/bin/bash
#echo ">>>>>>>>> $0: installing git <<<<<<<<<"
#yum install -y git  libgnome-keyring perl-Error perl-TermReadKey rsync
#
#echo ">>>>>>>>> $0: cloning PassWebTool <<<<<<<<<"
#cd /opt
#git clone https://github.com/maldex/PassWebTool.git
#cd PassWebTool
#rm -rf Addons/
#git pull || exit 255
#mkdir var/log
#
#echo ">>>>>>>>> $0: removing git <<<<<<<<<"
#yum remove -y git  libgnome-keyring perl-Error perl-TermReadKey rsync
#

echo ">>>>>>>>> $0: installing wget and tar <<<<<<<<<"
yum install -y wget unzip
echo ">>>>>>>>> $0: fetching master-branch of PassWebTool <<<<<<<<<"
cd /opt
wget https://github.com/maldex/PassWebTool/archive/master.zip
unzip master.zip && rm -f master.zip
mv PassWebTool-master PassWebTool
cd /opt/PassWebTool
rm -rf Addons

mkdir var/log

echo ">>>>>>>>> $0: removing wget and tar <<<<<<<<<"
yum remove -y wget unzip
echo ">>>>>>>>> $0: generating htpasswd <<<<<<<<<"
htpasswd -b -c var/lib/pwt.htpasswd pwt password 

