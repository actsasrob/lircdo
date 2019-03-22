#!/bin/bash

if [ -f servercert.pem ]; then
   echo "info: servercert.pem already exists. skipping creation of servercert.pem"
   sleep 3
else
   echo -ne "y\ny\n" | openssl ca -config openssl-ca-signing.cnf -policy signing_policy -extensions signing_req -out servercert.pem -infiles servercert.csr
fi

openssl x509 -in servercert.pem -text -noout


