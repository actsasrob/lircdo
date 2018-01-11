#!/bin/bash

touch index.txt
if [ ! -f serial.txt ]; then
   echo '01' > serial.txt
fi

if [ -f cacert.pem ]; then
   echo "info: cacert.pem already exists. skipping cacert.pem creation."
   sleep 3
else
   openssl req -x509 -config openssl-ca.cnf -newkey rsa:4096 -sha256 -nodes -out cacert.pem -outform PEM
fi

openssl x509 -purpose -in cacert.pem -inform PEM
