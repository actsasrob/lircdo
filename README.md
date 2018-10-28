# lircdo
Linux Inrared Remote Control (LIRC) Do. Node.js web application that provides actions that can be invoked by lircdo_ask Alexa Skills Kit lambda function. The lircdo application invokes shell scripts local to the server which emit IR signals using the LIRC service. IR emitter hardware is required.


# Installation

## Debian Jessie
Highly recommend using Raspbian with Debian Jessie operating system. I found the LIRC libraries under Debian Stretch to be unstable. After reverting back to Debian Jessie I've had no problems with the linux LIRC libraries.)
You can find the zip file containing Raspbian using Debian Jessie here: http://downloads.raspberrypi.org/raspbian/images/raspbian-2017-07-05/

Here's the command I use on Ubuntu 16.04 to burn the image to a 32GB SD card available as device /dev/mmcblk0:
unzip -p 2017-07-05-raspbian-jessie.zip | sudo dd of=/dev/mmcblk0 bs=4M conv=fsync

### Install LIRC packages
sudo apt-get install lirc

### Upgrade to node.js v4.x
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
sudo apt-get install nodejs

### Create unprivileged lirc user
sudo adduser lirc
sudo su - lirc
Change directory to where you want lircdo installed
git clone https://github.com/actsasrob/lircdo.git
cd lircdo
npm install

### reate the directory where LIRC scripts will reside. The steps below assume this directory is named 'lircscripts' inside the top-level lircdo directory
mkdir lircscripts
<See section regarding how to create LIRC scripts>

### Create node.js application .env file. This file is read by node.js application at startup to set various required environment variables.
cp env_file_example .env
chmod 600 .env

Edit .env and update environment variables as needed.
Set PORT to the port the application will listen on. This port must be accessible via internet.
Set APP_FQDN to fully qualified domain name (FQDN) of application. This address must resolve to your application from the internet.
Change value of all variables that end in \_SECRET. For security purposes DO NOT use the default values.
Set LIRCSCRIPTS_LOCATION to location of directory which contains LIRC shell scripts. Must be accessible to lirc user.
Initially set TEST_MODE to false. Set to true to test receiving LIRC actions from alexa lircdo skill without actually executing shell script.

NOTE: After updating .env you must restart the node.js application for changes to take effect.

### Generate self-signed cert/key.
Edit openssl/openssl-server.cnf and change DNS.1 to be the FQDN for your application. Add additional DNS aliases as desired by adding additional DNS.N lines.

Execute the openssl/make-all.sh script to create a CA cert/key, server key, server certificate signing request (CSR), and then sign the CSR using CA cert/key to create a self-signed server cert.

See below for example below:

cd openssl
./make-all.sh
Generating a 4096 bit RSA private key
............................................................................................................................................................++
......................++
writing new private key to 'cakey.pem'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [US]:
State or Province Name (full name) [MyState]:Nevada
Locality Name (eg, city) [MyTown]:Reno
Organization Name (eg, company) [Test CA, Limited]:
Organizational Unit (eg, division) [Server Research Department]:LIRCDO
Common Name (e.g. server FQDN or YOUR name) [Test CA]:ca.example.com
Email Address [test@example.com]:
Certificate purposes:
SSL client : No
SSL client CA : Yes
SSL server : No
SSL server CA : Yes
Netscape SSL server : No
Netscape SSL server CA : Yes
S/MIME signing : No
S/MIME signing CA : Yes
S/MIME encryption : No
S/MIME encryption CA : Yes
CRL signing : Yes
CRL signing CA : Yes
Any Purpose : Yes
Any Purpose CA : Yes
OCSP helper : Yes
OCSP helper CA : Yes
Time Stamp signing : No
Time Stamp signing CA : Yes
-----BEGIN CERTIFICATE-----
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
mggY1GX1BylHdt0+5UNM
-----END CERTIFICATE-----
Generating a 2048 bit RSA private key
.........+++
.......................+++
writing new private key to 'serverkey.pem'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [US]:
State or Province Name (full name) [MyState]:Nevada
Locality Name (eg, city) [MyTown]:Reno
Organization Name (eg, company) [Test CA, Limited]:LIRCDO
Common Name (e.g. server FQDN or YOUR name) [Test CA]:lirc.example.com
Email Address [test@example.com]:
verify OK
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=US, ST=Nevada, L=Reno, O=LIRCDO, CN=lirc.example.com/emailAddress=test@example.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:b8:26:a0:60:34:fb:c2:5e:ea:ef:17:50:17:77:
                    e4:aa:e9:0d:63:81:ff:46:b1:26:27:f3:a5:83:0b:
                    9a:15:df:e9:be:63:b4:5d:66:2a:1f:7d:ac:f8:cd:
                    c8:2d:88:53:59:6d:90:1b:ab:71:98:c6:df:7b:0e:
                    60:98:d6:8b:fe:7a:76:b2:0c:89:be:94:58:a2:f1:
                    1d:98:7b:6b:0d:5d:ee:86:58:a2:b9:70:2d:03:7c:
                    23:bd:ac:13:de:31:b6:06:26:df:9b:5b:ab:64:56:
                    83:6a:ab:cd:1c:e5:da:e4:ca:bb:ee:79:2b:4d:45:
                    17:b7:8b:c7:fd:0d:ff:18:15:9d:e1:f4:be:7e:87:
                    d3:64:9a:f4:c0:f8:4d:b3:f7:dc:8a:32:24:c3:01:
                    8c:92:39:67:e5:29:28:93:06:f5:bb:25:56:f2:ae:
                    b7:bd:ec:04:27:1b:51:0a:e5:44:d9:ac:52:8e:92:
                    cb:fe:02:bc:6d:e2:06:71:2a:b9:3c:7d:86:e0:07:
                    54:55:69:1a:b3:ce:3f:03:80:17:55:7b:62:77:cb:
                    a2:d3:15:fa:af:81:10:88:84:46:c2:0b:a3:94:f1:
                    72:d1:b0:90:8f:dd:0e:29:2a:8a:74:52:69:b6:81:
                    33:02:f7:9c:a9:2d:95:30:20:a2:bc:f2:27:0f:97:
                    18:6b
                Exponent: 65537 (0x10001)
        Attributes:
        Requested Extensions:
            X509v3 Subject Key Identifier:
                E1:C3:EA:9B:3C:58:92:87:06:9A:4D:05:44:0B:71:57:5E:C2:70:13
            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Key Usage:
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name:
                DNS:lirc.example.com, IP Address:127.0.0.1, IP Address:0:0:0:0:0:0:0:1
            Netscape Comment:
                OpenSSL Generated Certificate
    Signature Algorithm: sha256WithRSAEncryption
         ac:2e:dd:05:93:fe:21:0c:3d:e0:c7:ec:42:f7:ce:d9:b7:60:
         1f:40:ae:e7:f6:a8:15:e3:00:13:82:ea:03:65:be:cd:2e:f1:
         30:ae:68:ff:4d:e1:f5:a6:00:6a:f2:79:87:fb:52:0e:42:c9:
         56:42:ff:82:2b:37:c3:3c:d9:81:77:36:c0:b7:55:b4:bb:a0:
         46:0e:65:e3:4b:1d:50:f4:77:00:9b:4b:e9:12:31:d2:b0:83:
         f4:d3:3c:5c:93:99:19:d0:12:1c:54:e8:86:99:dd:bd:52:e2:
         b2:29:e1:85:3c:b3:8a:f9:1a:63:a9:49:12:72:37:bf:63:78:
         fd:86:e1:24:90:5e:31:7a:a4:e3:fe:8d:1c:c7:f8:4e:0e:6d:
         b2:d1:6e:a5:16:e1:10:c4:90:d0:b9:9f:0a:e4:42:4c:ce:3a:
         31:43:c3:ee:78:8b:a3:38:06:a1:ca:4a:3c:6e:fc:4e:bc:17:
         c6:f3:81:10:fd:ca:be:88:9e:33:f1:2c:a3:d3:66:ad:77:91:
         6d:68:3e:3d:7a:c4:a5:ee:66:1e:ff:e2:c4:91:f7:db:7c:c2:
         4b:a0:dc:e5:9e:b6:37:34:fd:84:db:ca:fe:00:c2:47:8a:3b:
         16:36:f1:0b:9a:cc:10:d5:0f:7b:ee:c8:a9:87:09:e0:ed:43:
         14:f1:45:2a
Using configuration from openssl-ca-signing.cnf
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
countryName           :PRINTABLE:'US'
stateOrProvinceName   :ASN.1 12:'Nevada'
localityName          :ASN.1 12:'Reno'
organizationName      :ASN.1 12:'LIRCDO'
commonName            :ASN.1 12:'lirc.example.com'
Certificate is to be certified until Oct 22 23:46:07 2020 GMT (1000 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=Nevada, L=Reno, O=Test CA, Limited, OU=LIRCDO, CN=ca.example.com/emailAddress=test@example.com
        Validity
            Not Before: Jan 26 23:46:07 2018 GMT
            Not After : Oct 22 23:46:07 2020 GMT
        Subject: C=US, ST=Nevada, L=Reno, O=LIRCDO, CN=lirc.example.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:b8:26:a0:60:34:fb:c2:5e:ea:ef:17:50:17:77:
                    e4:aa:e9:0d:63:81:ff:46:b1:26:27:f3:a5:83:0b:
                    9a:15:df:e9:be:63:b4:5d:66:2a:1f:7d:ac:f8:cd:
                    c8:2d:88:53:59:6d:90:1b:ab:71:98:c6:df:7b:0e:
                    60:98:d6:8b:fe:7a:76:b2:0c:89:be:94:58:a2:f1:
                    1d:98:7b:6b:0d:5d:ee:86:58:a2:b9:70:2d:03:7c:
                    23:bd:ac:13:de:31:b6:06:26:df:9b:5b:ab:64:56:
                    83:6a:ab:cd:1c:e5:da:e4:ca:bb:ee:79:2b:4d:45:
                    17:b7:8b:c7:fd:0d:ff:18:15:9d:e1:f4:be:7e:87:
                    d3:64:9a:f4:c0:f8:4d:b3:f7:dc:8a:32:24:c3:01:
                    8c:92:39:67:e5:29:28:93:06:f5:bb:25:56:f2:ae:
                    b7:bd:ec:04:27:1b:51:0a:e5:44:d9:ac:52:8e:92:
                    cb:fe:02:bc:6d:e2:06:71:2a:b9:3c:7d:86:e0:07:
                    54:55:69:1a:b3:ce:3f:03:80:17:55:7b:62:77:cb:
                    a2:d3:15:fa:af:81:10:88:84:46:c2:0b:a3:94:f1:
                    72:d1:b0:90:8f:dd:0e:29:2a:8a:74:52:69:b6:81:
                    33:02:f7:9c:a9:2d:95:30:20:a2:bc:f2:27:0f:97:
                    18:6b
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                E1:C3:EA:9B:3C:58:92:87:06:9A:4D:05:44:0B:71:57:5E:C2:70:13
            X509v3 Authority Key Identifier:
                keyid:AA:A7:B1:56:F7:E2:5C:9F:E0:4B:B4:80:F5:C9:4D:C3:37:BD:03:47

            X509v3 Basic Constraints:
                CA:FALSE
            X509v3 Key Usage:
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name:
                DNS:lirc.example.com, IP Address:127.0.0.1, IP Address:0:0:0:0:0:0:0:1
            Netscape Comment:
                OpenSSL Generated Certificate
    Signature Algorithm: sha256WithRSAEncryption
         39:97:47:63:ff:58:59:98:0f:47:b8:2c:37:36:52:85:72:04:
         ab:b6:ab:2e:38:71:71:c6:17:f6:de:4a:28:7f:f7:a7:67:03:
         01:0c:57:68:77:4d:53:f7:2a:1c:c8:7f:3a:1a:f5:35:6b:00:
         86:11:f6:7e:ab:2b:b4:4a:ea:45:48:6e:9e:17:d2:5d:64:b8:
         de:36:0c:d2:14:10:f0:4f:18:ea:03:e5:a9:11:61:9e:8a:71:
         78:56:85:5b:89:df:15:0c:ce:07:ce:d0:1c:fa:a3:64:4d:30:
         d2:c6:31:dc:b6:2f:91:e9:60:44:62:f2:a8:71:15:0c:5f:b9:
         0b:c7:f1:d5:b8:35:e0:49:17:da:57:f1:02:46:6a:32:89:59:
         fc:a7:1f:3a:8b:f5:25:2c:bc:cb:d4:16:1e:32:3b:46:c6:2a:
         1e:f8:fd:6e:72:86:c1:b3:07:2f:01:0c:0e:37:ca:c5:b2:f6:
         56:01:66:a9:87:59:c6:ba:43:75:52:7e:b2:d3:15:1a:cd:1f:
         84:dd:cc:b7:c7:03:02:e2:21:4e:67:a3:29:7e:c2:68:81:53:
         88:cd:71:77:f3:5c:9f:cf:87:4a:f8:5e:2d:8c:cf:9e:46:0d:
         ba:3e:60:6f:ba:3b:27:c8:d8:34:4c:32:80:a9:cc:7e:06:f9:
         d9:77:f8:8c:2c:81:5f:01:9e:3f:e2:ee:5b:4a:60:67:dc:c9:
         90:1e:47:f0:f5:57:14:ff:f3:a7:13:9f:78:1b:38:dd:95:c8:
         99:3d:9f:7b:21:c0:67:bb:bf:5a:99:3f:a7:c3:53:81:7d:b9:
         26:3a:c1:9f:1c:8e:da:7e:a1:98:0a:ed:af:07:5a:af:c7:51:
         9b:58:21:7f:d2:17:3e:49:f4:fd:cc:de:6b:39:ec:9c:62:8f:
         82:b6:f4:26:65:11:15:95:15:3f:41:f1:0a:24:4c:e9:ee:81:
         ea:4a:20:e7:0d:e1:e9:24:4c:0b:c9:c9:e1:17:55:cf:2b:9c:
         e8:e7:9f:25:bd:e6:e7:dd:2b:6a:d9:36:8b:d2:99:60:f6:e2:
         b0:af:38:25:df:c5:99:b0:8b:37:ed:3a:ae:19:c7:85:34:57:
         45:0e:c8:37:8d:a3:2d:d8:85:ba:f3:40:e1:f8:b0:2a:30:e5:
         a4:f8:c8:03:44:2f:e9:d2:42:d7:64:06:27:3f:7b:4e:d9:83:
         b3:44:32:9c:c6:50:28:c6:e9:ca:4c:dd:19:7b:85:56:02:cc:
         0f:a8:6c:81:04:84:46:c4:bd:42:f4:99:8e:7a:0d:e9:93:6a:
         ea:bf:ee:57:bc:c3:c1:c3:1d:b2:3d:56:f5:e0:ac:39:49:3e:
         5c:2b:14:33:00:d5:84:0a
info: installing cacert.pem and server cert/key files to ../sslcert

ls -al ../sslcert/
total 24
drwxr-xr-x  2 lirc lirc 4096 Jan 26 18:46 .
drwxr-xr-x 11 lirc lirc 4096 Jan 26 18:43 ..
-rw-r--r--  1 lirc lirc 2155 Jan 26 18:46 cacert.pem
-rw-r--r--  1 lirc lirc 6123 Jan 26 18:46 servercert.pem
-rw-r--r--  1 lirc lirc 1704 Jan 26 18:46 serverkey.pem

cd ..
### Generate catalog
./generate_json_catalogs.py
<snip>
info: internal catalog written to ./catalog_internal.json

This produces ./catalog_internal.json which is read by the node.js application on startup. This file maps the various HTTPS action callbacks to 0 or 1 LIRC scripts. If a script is found that implements the desired action then it is executed by the node.js application to perform the action (which usually means an IR signal is emitted to control some piece of hardware).

NOTE: Re-run generate_json_catalogs.py anytime changes are made to scripts in the LIRC scripts directory then restart the node.js application.





