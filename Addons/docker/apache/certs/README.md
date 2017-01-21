# create CA and Certs self signed

## create CA
```
# generate CA Key
openssl genrsa -aes256 -out CertAuth.key.org 2048
# unlocking CA Key - not sure this is a good idea
openssl rsa -in CertAuth.key.org -out CertAuth.key
# generating certificate
openssl req -new -x509 -days 3650 -key CertAuth.key -out CertAuth.crt -subj "/C=SS/ST=SelfSigned/L=SelfSigned/O=self-signed ltd inc gmbh sa ag/OU=another self-signed certificate authority/CN=self.signed.private/emailAddress=does@not.exist"
# insepct this certificate
openssl x509 -in CertAuth.crt -text -noout
```

## generate default vhost cert
```
openssl genrsa -aes256 -out default.key.org 2048
openssl rsa -in default.key.org -out default.key
openssl req -new -key default.key -out default.csr -subj "/C=SS/ST=SelfSigned/L=Default vhost/O=some private webserver/OU=department of webservers/CN=default.private/emailAddress=no@one.here"
openssl x509 -req -in default.csr -out default.crt -sha256 -CA CertAuth.crt -CAkey CertAuth.key -CAcreateserial -days 1825
openssl x509 -in default.crt -text -noout
```

## generate PassWebTool vhost cert
```
openssl genrsa -aes256 -out PassWebTool.key.org 2048
openssl rsa -in PassWebTool.key.org -out PassWebTool.key
openssl req -new -key PassWebTool.key -out PassWebTool.csr -subj "/C=SS/ST=SelfSigned/L=PassWebTool/O=Private/OU=Password Services/CN=PassWebTool/emailAddress=no@one.here/subjectAltName=DNS.1=PassWebTool.local,DNS.2=PassWebTool.private,DNS.3=PassWebTool.internal"
openssl x509 -req -in PassWebTool.csr -out PassWebTool.crt -sha256 -CA CertAuth.crt -CAkey CertAuth.key -CAcreateserial -days 1825
openssl x509 -in PassWebTool.crt -text -noout
```
