#!/bin/bash
echo ">>> this is $0 $@"

echo ">>> including hostname into default vhost index.html"
echo "<sub>(this is `hostname --fqdn` started `date`)</sub><br>" >> /var/www/html/index.html
echo ">>> dumping config"
httpd -v
httpd -S
echo ">>> exec httpd"
exec httpd -DFOREGROUND
echo ">>> httpd exited ($?)"
