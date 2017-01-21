#!/bin/bash
echo ">>>>>>>>> $0: installing and configuring apache <<<<<<<<<"

yum install -y httpd mod_evasive mod_ssl
systemctl enable httpd 
cd /etc/httpd

echo "<title>default vhost</title>
<body>You just hit the default vhost of this webserver. Check your URL.</title>
" > /var/www/html/index.html

# configure defaults
sed -i 's/^ServerAdmin .*/ServerAdmin no@bo.dy/' conf/httpd.conf
sed -i 's/^#ServerName .*/ServerName '`hostname`'/' conf/httpd.conf
 
# disable conf.d/ include
sed -i '/IncludeOptional conf.d\/\*.conf/s/^/#### DEFAULT VHOST first !!! #### /' conf/httpd.conf

echo "
IncludeOptional             conf/httpd.conf.defaultvhost
IncludeOptional             conf.d/*.conf" >> conf/httpd.conf
# harden apache
echo ">>> Hardening Apache"
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
 sed -i '/'${e}'/s/^#;//' conf.modules.d/*
 done
