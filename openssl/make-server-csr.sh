#!/bin/bash

if [ -f servercert.csr ]; then
   echo "info: servercert.csr already exists. skipping creation of servercert.csr"
   sleep 3
else
   openssl req -config openssl-server.cnf -newkey rsa:2048 -sha256 -nodes -out servercert.csr -outform PEM
fi

openssl req -text -noout -verify -in servercert.csr

