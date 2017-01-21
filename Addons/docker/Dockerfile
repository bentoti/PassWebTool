# vi Dockerfile; docker build -t pwt . && docker run -p 80:80 -p 443:443 -i -t pwt /bin/bash
FROM    centos:7.3.1611
RUN    yum upgrade -y && yum clean all

COPY	10-deps.sh /10-deps.sh
RUN	/10-deps.sh

COPY 	20-apache.sh /20-apache.sh
RUN	/20-apache.sh
COPY	apache/certs /etc/httpd/certs
COPY	apache/httpd.conf.defaultvhost /etc/httpd/conf/httpd.conf.defaultvhost
COPY	apache/vhost-PassWebTool.conf /etc/httpd/conf.d/vhost-PassWebTool.conf
RUN	httpd -S


COPY	30-clone.sh /30-clone.sh
RUN	/30-clone.sh
RUN	chown root:apache      /opt/PassWebTool/etc/*
RUN	chown -R root:root     /opt/PassWebTool/bin/
RUN	chown -R apache:root   /opt/PassWebTool/var/*

RUN	rm [0-9][0-9]-*.sh

EXPOSE 	80:80 443:443
CMD	["/usr/sbin/httpd","-DFOREGROUND"]
