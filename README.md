# About
When writing scripts for infrastructure automation i often end up at a point where i need a plaintext password for a
certain service. MySQL, Coldfusiuon Administrator, Webinterfaces to appliances, etc. are notorious unaware of public-
private key mechanisms and i often call http://user:pass@somewhere in a script.

PassWebTool eliminates the need to have that Password in the script itself but can be accessed whenever needed.

## How it works
PassWebTool is a Python script which interfaces between CGI(or CLI) and a KeePass KDB Database. You can acquire a
specific Password by requesting a certain Identifier (PWID), like this:
```
# wget --post-data="pwid=Q8HI5R" -qO - https://PassWebTool/get.py   #--no-check-certificate
username=mysql-backup
service=MySQL
notes=used for sql exports
host=databaseserver.local
pwid=Q8HI5R
password=this-is-the-very-password
```
or as json:
```
# wget --post-data="pwid=Q8HI5R&mode=json" -qO - https://PassWebTool/get.py 
{"username": "mysql-backup", "service": "MySQL", "notes": "used for sql exports", "host": "databaseserver.local", "pwid": "Q8HI5R", "password": "this-is-the-very-password"}
```
or straight as arguments?
```
# wget --post-data="pwid=Q8HI5R&mode=mysql" -qO - https://PassWebTool/get.py | xargs mysql
```

PassWebTool features a list and simpe edit interfaces. Just create an empty KeePass file, configure it's location and
Password in pwt.ini, and start adding your passwords via webui. While adding a entry, a pwid will given to you. Use
get.py?pwid=<pwid> to fetch that password or entry.

# usage
see pwt_client.sh

# Installation
Reference system is a CentOS 7. Please use 'keepassx' to create the initial KDB backend file, other tools might not work fine.

## base requirements
```
yum install -y epel-release
yum install -y httpd mod_ssl python-pip python-devel autoconf git gcc   redhat-rpm-config
pip install --upgrade pip
pip install keepass
pip install simplejson

vi /etc/httpd/conf/httpd.conf /etc/httpd/conf.d/vhost-pwt.conf ; systemctl restart httpd

htpasswd -c /opt/PassWebTool/etc/pwt.htpasswd pwt
systemctl enable httpd
```
## additional for X11 keepassx
```
yum groupinstall -y "X Window System"
yum install -y xorg-x11-fonts-Type1 keepassx
```
## clone
```
cd /opt
git clone <project_url>
cd PassWebTool
mkdir var/log
```

## setup permissions
```
chown root:apache      etc/pwt.ini
chown -R root:root     bin/
chown -R apache:root   var/*
```

## apache vhost
```
see vhost-PassWebTool.conf
```

