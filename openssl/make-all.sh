#!/bin/bash

FQDN=$1

./make-cacert-pem.sh
./make-server-csr.sh $FQDN
./make-server-cert.sh

echo "info: installing cacert.pem and server cert/key files to ../sslcert"
mkdir -p ../sslcert 2> /dev/null
cp -f cacert.pem ../sslcert
cp -f servercert.pem ../sslcert
cp -f serverkey.pem ../sslcert
chmod 640 ../sslcert/*.pem
