# $Id: //gbl/SF/PassWebTool/README.txt#1 $
h1. PassWebTool
Purpose: make passwords from a KeePass Safe available through HTTP(S)
Motivation: often there's no PubPriv. Key authentication available for certain Services (e.g. MySql), but you need to
have a password for your automation anyway. PassWebTool let's you acquire your password though HTTP(S). This removes
the necessity to store the password plaintext in your script, on your source or target system, or use no-passwd accounts.

imagine:  mysqldump ... -U backup -P `wget -q0 - https://PassWeb/get?pwid=45346643435464322`

h2. internals
We call it PWID - PassWordIDentification, but it's actually only the URL field in KeePass.
Titles are abused for the Hostname/Service:  HOSTNAME::SERVICE

h1. Usage
Getting a list of entries:
 ./PassWebToolList.py
 wget -q0 - http://localhost/cgi-bin/PassWebToolList.py

Add a password (will return new PWID):
 ./PassWebToolAdd.py -H host1234 -S service1234 -U user1234 -P pass1234
 wget --post-data='host=dihei&service=juheee&username=ich&password=miiispasswort' -qO - http://localhost/cgi-bin/PassWebToolAdd.py

Get a specific Password:
 ./PassWebToolGet.py -I 8c5900601ebdade4f33e93e22b3077de
 wget --post-data='pwid=8c5900601ebdade4f33e93e22b3077de' -qO - http://localhost/cgi-bin/PassWebToolGet.py

 import requests
print requests.post("http://localhost/cgi-bin/PassWebToolGet.py", data={'pwid': '958c6a28cd3ebf2496962e9132931bba'}).text


h1. Installation
h2. basics



chown root:apache   etc/pwt.ini
chown -R root:root     bin
chown -R apache:root  var



<VirtualHost *:80>
    ServerName      PassWebTool
    ServerAlias     PassWebTool.local PassWebTool.private
    Redirect        /       https://PassWebTool
</VirtualHost>
# http://www.the-art-of-web.com/system/apache-authorization/
<VirtualHost *:443>
    ServerName      PassWebTool
    ServerAlias     PassWebTool.local PassWebTool.private
    CustomLog       logs/PassWebTool_log common
    ErrorLog        logs/PassWebTool_err
    DocumentRoot    /opt/PassWebTool/bin
    LimitRequestBody 4096

    SetEnv cfgfile ../etc/crapo.ini

    <Directory /opt/PassWebTool/bin>
        Alias / get.py
        #DirectoryIndex  get.py
        Options +ExecCGI
        AddHandler cgi-script .py
        # requirements for 'get.py' and DirectoryIndex calls
        <RequireAll>
            Require ip   10.0.0.0/8  172.16.0.0/12  192.168.0.0/16 127.0.0.1/32
        </RequireAll>
        <FilesMatch "(?<!get.py)$">
            # requirements for all other calls like 'list.py' etc
            <RequireAll>
                Require ip   10.0.0.0/8  172.16.0.0/12  192.168.0.0/16 127.0.0.1/32
                AuthType Basic
                AuthName "PassWebTool"
                AuthUserFile "/opt/PassWebTool/etc/pwt.htpasswd"
                Require valid-user
            </RequireAll>
        </FilesMatch>

    </Directory>

    SSLEngine               on
    SSLProtocol             all -SSLv2 -SSLv3 -TLSV1
    SSLCipherSuite          HIGH:MEDIUM:!aNULL:!MD5:!SSLv3:!SSLv2:!TLSv1
    SSLCertificateChainFile /etc/httpd/ssl/CertAuth.crt
    SSLCertificateFile      /etc/httpd/ssl/PassWebTool.crt
    SSLCertificateKeyFile   /etc/httpd/ssl/PassWebTool.key
</VirtualHost>
