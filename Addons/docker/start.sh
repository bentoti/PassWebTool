#!/bin/bash
echo ">>> including hostname into default vhost index.html"
echo "<sub>(this is `hostname --fqdn` started `date`)</sub><br>" >> /var/www/html/index.html
echo ">>> dumping config"
httpd -S
echo ">>> starting httpd"

httpd -DFOREGROUND
echo ">>> httpd exited ($?)"
