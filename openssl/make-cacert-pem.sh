#!/bin/bash

touch index.txt
if [ ! -f serial.txt ]; then
   echo '01' > serial.txt
fi

if [ -f cacert.pem ]; then
   echo "info: cacert.pem already exists. skipping cacert.pem creation."
   sleep 3
else
   echo -ne "\n\n\nCA\nLIRCDO\nlircdoca\nlircdoca@example.com\n" | openssl req -x509 -days 3000 -config openssl-ca.cnf -newkey rsa:4096 -sha256 -nodes -out cacert.pem -outform PEM
fi

openssl x509 -purpose -in cacert.pem -inform PEM
