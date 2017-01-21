
#h2. Install Apache with SSL
yum install -y httpd mod_evasive mod_ssl
systemctl enable httpd 

echo "<title>default vhost</title>
<body>You just hit the default vhost of this webserver. Check your URL.</title>
" > /var/www/html/index.html

cd /etc/httpd
tar -zcf "http-last-config-`date +%Y%m%d`-${HOSTNAME}.tgz" *
 
# configure defaults
sed -i 's/^ServerAdmin .*/ServerAdmin no@bo.dy/' conf/httpd.conf
sed -i 's/^#ServerName .*/ServerName '`hostname`'/' conf/httpd.conf
 
# disable conf.d/ include
sed -i '/IncludeOptional conf.d\/\*.conf/s/^/#### DEFAULT VHOST first !!! #### /' conf/httpd.conf

echo "
IncludeOptional             conf/httpd.conf.defaultvhost
IncludeOptional             conf.d/*.conf" >> conf/httpd.conf

vi conf/httpd.conf.defaultvhost
# custom settings
UseCanonicalName            Off
DeflateCompressionLevel     1
HostnameLookups             on

# ssl
Listen                      443 https
SSLPassPhraseDialog         exec:/usr/libexec/httpd-ssl-pass-dialog
SSLSessionCache             shmcb:/run/httpd/sslcache(512000)
SSLSessionCacheTimeout      5
SSLRandomSeed               startup file:/dev/urandom  256
SSLRandomSeed               connect builtin
SSLCryptoDevice             builtin
SSLProtocol                 all -SSLv2 -SSLv3 -TLSV1
SSLCipherSuite              HIGH:MEDIUM:!aNULL:!MD5:!SEED:!IDEA:!SSLv3:!SSLv2:!TLSv1

# default vhosts
<VirtualHost *:80>
    RewriteEngine           on
    RewriteCond             %{HTTPS}    off
    RewriteRule             (.*)        https://%{HTTP_HOST}%{REQUEST_URI}
</VirtualHost>

<VirtualHost *:443>
    DocumentRoot            /var/www/html
    SSLEngine               on
    SSLCertificateChainFile certs/CertAuth.crt
    SSLCertificateFile      certs/default.crt
    SSLCertificateKeyFile   certs/default.key
</VirtualHost>
####################33

vi conf.d/vhost-PassWebTool.conf
<VirtualHost *:443>
    ServerName        PassWebTool
    ServerAlias       PassWebTool.local PassWebTool.private PassWebTool.internal
    DocumentRoot      /opt/PassWebTool/bin
    LimitRequestBody  4096

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
    SSLCertificateChainFile /etc/httpd/certs/CertAuth.crt
    SSLCertificateFile      /etc/httpd/certs/PassWebTool.crt
    SSLCertificateKeyFile   /etc/httpd/certs/PassWebTool.key
</VirtualHost>

##### harden Apache
# ---- Disable all apache modules
sed -i '/^#;/!s/^/#;/' conf.d/autoindex.conf
sed -i '/^#;/!s/^/#;/' conf.d/userdir.conf
sed -i '/^#;/!s/^/#;/' conf.d/welcome.conf
sed -i '/^#;/!s/^/#;/' conf.d/ssl.conf
sed -i '/^#;/!s/^/#;/' conf.modules.d/*

# ---- Reenable basic modules
sed -i 's/^#;//' conf.modules.d/00-mpm.conf
sed -i 's/^#;//' conf.modules.d/01-cgi.conf
sed -i 's/^#;//' conf.modules.d/00-ssl.conf
sed -i 's/^#;//' conf.modules.d/00-systemd.conf

# reenableing the following modules
m="systemd_module access_compat_module actions_module alias_module allowmethods_module auth_basic_module auth_digest_module authn_anon_module authn_core_module authn_file_module authz_core_module authz_groupfile_module authz_host_module authz_user_module data_module deflate_module dir_module echo_module env_module expires_module ext_filter_module filter_module headers_module include_module log_config_module logio_module mime_magic_module mime_module negotiation_module remoteip_module reqtimeout_module rewrite_module setenvif_module status_module substitute_module unique_id_module unixd_module version_module vhost_alias_module log_debug_module log_debug_module mod_slotmem_shm mod_socache_shmcb"

for e in ${m}; do
 sed -i '/'${e}'/s/^#;//' conf.modules.d/* || echo "F: ${e}" && echo "O: ${e}"
 done
httpd -S

systemctl restart httpd

#################################################################################3

mkdir -p /etc/httpd/certs
cd /etc/httpd/certs
 
# generate CA Key   # password is 'password'
openssl genrsa -aes256 -out CertAuth.key.org 2048
# unlocking CA Key - not sure this is a good idea
openssl rsa -in CertAuth.key.org -out CertAuth.key
# generating certificate
openssl req -new -x509 -days 3650 -key CertAuth.key -out CertAuth.crt -subj "/C=SS/ST=SelfSigned/L=SelfSigned/O=self-signed ltd inc gmbh sa ag/OU=another self-signed certificate authority/CN=self.signed.private/emailAddress=does@not.exist"
# insepct this certificate
openssl x509 -in CertAuth.crt -text -noout

# generate default vhost key
openssl genrsa -aes256 -out default.key.org 2048
openssl rsa -in default.key.org -out default.key
openssl req -new -key default.key -out default.csr -subj "/C=SS/ST=SelfSigned/L=Default vhost/O=some private webserver/OU=department of webservers/CN=default.private/emailAddress=no@one.here"
openssl x509 -req -in default.csr -out default.crt -sha256 -CA CertAuth.crt -CAkey CertAuth.key -CAcreateserial -days 1825
openssl x509 -in default.crt -text -noout


# generate PassWebTool vhost key
openssl genrsa -aes256 -out PassWebTool.key.org 2048
openssl rsa -in PassWebTool.key.org -out PassWebTool.key
openssl req -new -key PassWebTool.key -out PassWebTool.csr -subj "/C=SS/ST=SelfSigned/L=PassWebTool/O=Private/OU=Password Services/CN=PassWebTool/emailAddress=no@one.here/subjectAltName=DNS.1=PassWebTool.local,DNS.2=PassWebTool.private,DNS.3=PassWebTool.internal"
openssl x509 -req -in PassWebTool.csr -out PassWebTool.crt -sha256 -CA CertAuth.crt -CAkey CertAuth.key -CAcreateserial -days 1825
openssl x509 -in PassWebTool.crt -text -noout

################################################################
yum install -y python-pip  python-backports python-backports-ssl_match_hostname python-setuptools
yum install -y python-devel 
yum install -y gcc  cpp glibc-devel glibc-headers kernel-headers libmpc mpfr

pip install --upgrade pip
pip install simplejson keepass

yum remove -y python-pip  python-backports python-backports-ssl_match_hostname python-setuptools
yum remove -y python-devel 
yum remove -y gcc  cpp glibc-devel glibc-headers kernel-headers libmpc mpfr

################################################################

yum install -y git  libgnome-keyring perl-Error perl-TermReadKey rsync

cd /opt
git clone https://github.com/maldex/PassWebTool.git

yum remove -y git  libgnome-keyring perl-Error perl-TermReadKey rsync

cd PassWebTool
htpasswd -b -c etc/pwt.htpasswd pwt password
mkdir var/log
chown root:apache      etc/pwt.ini
chown -R root:root     bin/
chown -R apache:root   var/*


################################################################

systemctl restart httpd





