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

echo ">>>>>>>>> $0: moving to volume <<<<<<<<<"
cd /opt/PassWebTool
if [ ! -e /var/PassWebData ]; then
	mkdir -v /var/PassWebData
fi

if [ ! -e /var/PassWebData/lib ]; then
	mv -v var/lib /var/PassWebData
	rm -rf var/
fi

if [ ! -e /var/PassWebData/log/ ]; then
	mkdir -v /var/PassWebData/log/
	mv -v /var/log/httpd /var/PassWebData/log/ 
	ln -v -s /var/PassWebData/log/httpd /var/log/httpd
fi

if [ ! -e var/ ]; then
	ln -v -s /var/PassWebData/ ./var
fi

echo ">>>>>>>>> $0: chowning <<<<<<<<<"

chown -v root:apache      /opt/PassWebTool/etc/*
chown -v -R root:root     /opt/PassWebTool/bin/
chown -v -R apache:root   /opt/PassWebTool/var/*
chown -v root:root        /opt/PassWebTool/var/lib/pwt.htpasswd
