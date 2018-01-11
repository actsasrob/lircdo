#!/bin/bash

./make-cacert-pem.sh
./make-server-csr.sh
./make-server-cert.sh

echo "info: installing cacert.pem and server cert/key files to ../sslcert"
mkdir ../sslcert 2> /dev/null
cp -f cacert.pem ../sslcert
cp -f servercert.pem ../sslcert
cp -f serverkey.pem ../sslcert

