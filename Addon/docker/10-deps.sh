#!/bin/bash
echo ">>>>>>>>> $0: installing dependencies for python-keypass building <<<<<<<<<"

# unfortunately, python-keypass, even though PIP, requires building with gcc
pkgs="python2-pip  python-backports python-backports-ssl_match_hostname python-setuptools"
pkgs="${pkgs} gcc  cpp glibc-devel glibc-headers kernel-headers libmpc mpfr libgomp"
pkgs="${pkgs} python-devel"

yum install -y epel-release
yum install -y ${pkgs}

echo ">>>>>>>>> $0: installing python-keypass <<<<<<<<<"
/usr/bin/pip install --upgrade pip
/usr/bin/pip install simplejson keepass || exit 255

echo ">>>>>>>>> $0: removing dependencies for python-keypass <<<<<<<<<"
yum remove -y ${pkgs}
yum remove -y epel-release
