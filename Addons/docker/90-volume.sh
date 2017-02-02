#!/bin/bash
echo ">>>>>>>>> $0: moving out parts that should stay persistent <<<<<<<<<"
mkdir /var/PassWebData
if [ -e /var/PassWebData ]; then
	mv /opt/PassWebTool/var/lib /var/PassWebData
	mv /opt/PassWebTool/var/log 	/var/PassWebData
	rmdir /opt/PassWebTool/var
        ln -s /var/PassWebData /opt/PassWebTool/var
        
	mv /var/log/httpd /var/PassWebData/log/ && ln -s /var/PassWebData/log/httpd /var/log/httpd
fi

