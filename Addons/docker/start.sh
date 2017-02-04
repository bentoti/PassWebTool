#!/bin/bash
echo ">>> this is $0 $@"

echo ">>>>>>>>> $0: starting <<<<<<<<<"
pushd "`grep DocumentRoot /etc/httpd/conf.d/vhost-PassWebTool.conf | awk '{print $2}'`/.." >/dev/null
echo ">>> use \"`pwd`/var\" ps persistent storage"
chown -v -R apache:root   var/*
chown -v root:root        var/lib/pwt.htpasswd
popd >/dev/null


echo ">>> including hostname (`hostname`) into default vhost index.html"
echo "<sub>(this is `hostname --fqdn` started `date`)</sub><br>" >> /var/www/html/index.html
echo ">>> dumping config"
httpd -v
httpd -S
echo ">>> exec httpd"
exec httpd -DFOREGROUND
echo ">>> httpd exited ($?)"
