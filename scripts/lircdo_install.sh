#!/bin/bash

echo
echo "info: installing Let's Encrypt certbot-auto script used to generate TLS certificates..."
wget https://dl.eff.org/certbot-auto
if [ "$?" -ne 0  ]; then
   echo "error: could not download certbot-auto. exiting..."
   exit 1
else
   echo "info: certbot-auto successfully downloaded."
fi

echo
echo "info: downloading certbot-auto.asc to verify integrity of certbot-auto..."
wget -N https://dl.eff.org/certbot-auto.asc
if [ "$?" -ne 0  ]; then
   echo "error: could not download certbot-auto.asc to verify certbox-auto install. exiting..."
   exit 1
else
   echo "info: certbot-auto.asc successfully downloaded."
fi

echo
echo "info: installing trusted gpg key for Let's Encrypt certbot-auto..."
gpg2 --keyserver pool.sks-keyservers.net --recv-key A2CFB51FA275A7286234E7B24D17C995CD9775F2

if [ "$?" -ne 0 ]; then
   echo "error: failed to install trusted gpg key. exiting..."
   exit 1
else
   echo "info: gpg key installed"
fi

echo
echo "info: verifying integrity of Let's Encrypt certbox-auto script..."
gpg2 --trusted-key 4D17C995CD9775F2 --verify certbot-auto.asc certbot-auto 2>&1 | grep "gpg: Good signature"

if [ "$?" -ne 0 ]; then
   echo "error: failed to validate certbot-auto script. exiting..."
   exit 1
else
   echo "info: certbot-auto script successfully verified" 
fi   

chmod a+x ./certbot-auto
# ./certbot-auto --help

#sudo ./certbot-auto certonly --standalone --agree-tos -m acts.as.rob@gmail.com --preferred-challenges http  -d lirc.robhughes.net
