# vi Dockerfile; docker build -t pwt . && docker run -p 80:80 -p 443:443 -i -t pwt /bin/bash
FROM    centos:7.3.1611
COPY	Dockerfile /Dockerfile
#RUN     yum upgrade -y && yum clean all

COPY	[0-9][0-9]-*.sh /

RUN	/10-deps.sh

RUN	/20-apache.sh
COPY	apache/certs /etc/httpd/certs
COPY	apache/httpd.conf.defaultvhost /etc/httpd/conf/httpd.conf.defaultvhost
COPY	apache/vhost-PassWebTool.conf /etc/httpd/conf.d/vhost-PassWebTool.conf
RUN	httpd -S


RUN	/30-install.sh
RUN	chown root:apache      /opt/PassWebTool/etc/*
RUN	chown -R root:root     /opt/PassWebTool/bin/
RUN	chown -R apache:root   /opt/PassWebTool/var/*.kdb

#§:wqRUN	/90-volume.sh

#§RUN	rm [0-9][0-9]-*.sh

COPY	start.sh /start.sh

#VOLUME	/var/PassWebData
EXPOSE 	80:80 443:443
CMD	["/start.sh"]
#CMD	["/usr/sbin/httpd","-DFOREGROUND"]
