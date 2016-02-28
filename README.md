# About
When writing scripts for infrastructure automation i often end up at a point where i need a plaintext password for a
certain service. MySQL, Coldfusiuon Administrator, Webinterfaces to appliances, etc. are notorious unaware of public-
private key mechanisms and i often call http://user:pass@womewhere in a script.

PassWebTool eliminates the need to have that Password in the script itself but can be accessed whenever needed.

## How it works
PassWebTool is a Python script which interfaces between CGI(or CLI) and a KeePass KDB Database. You can acquire a
specific Password by requesting a certain Identifier (PWID)

wget --post-data="pwid=79IXES" -qO - --no-check-certificate https://PassWebTool/get.py


# usage
```
import requests
print requests.post("https://PassWebTool/Get.py", data={'pwid': '79IXES'}).text
```

# Installation
Reference system is CentOZ7 or Fedora around 23

## base requirements
- apache
- python
- python keepass lib

## setup permissions
```
chown root:apache      etc/pwt.ini
chown -R root:root     bin/
chown -R apache:root   var/
```

## apache vhost
```
<VirtualHost *:80>
    ServerName      PassWebTool
    ServerAlias     PassWebTool.local PassWebTool.private
    Redirect        /       https://PassWebTool
</VirtualHost>
<VirtualHost *:443>
    ServerName      PassWebTool
    ServerAlias     PassWebTool.local PassWebTool.private
    CustomLog       logs/PassWebTool_log common
    ErrorLog        logs/PassWebTool_err
    DocumentRoot    /opt/PassWebTool/bin
    LimitRequestBody 4096

#    SetEnv cfgfile ../etc/somewhere.pwt.ini

    <Directory /opt/PassWebTool/bin>
        DirectoryIndex  get.py
        Options +ExecCGI
        AddHandler cgi-script .py

        # requirements for 'get.py' and DirectoryIndex calls  (public access for pwid only)
        <RequireAll>
            Require ip   10.0.0.0/8  172.16.0.0/12  192.168.0.0/16  127.0.0.1/32
        </RequireAll>

        <FilesMatch "(?<!get.py)$">
            # requirements for all calls not matchin 'get.py' (administrative access to edit.py and list.py )
            <RequireAll>
                Require ip   10.0.0.0/8  172.16.0.0/12  192.168.0.0/16  127.0.0.1/32
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
```